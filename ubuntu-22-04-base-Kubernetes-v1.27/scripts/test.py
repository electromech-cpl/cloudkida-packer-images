#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Automated CUR Query and E-mail Delivery
This tool executes CUR queries(query strings are defined in config.yml) via Athena, 
download to local path, convert format(csv to xlsx), combine multiple files to single one(add graph if needed), 
and sends it to configured recipients via SES
"""


__author__ = "Na Zhang"
__version__ = "v1.0"

import boto3
import botocore
import json
import time
import os
import sys
import datetime
from datetime import date
import re
import signal
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), "./package"))


import pandas as pd

import yaml

#email lib
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.utils import COMMASPACE, formatdate
from botocore.exceptions import ClientError







# =========== Parameters Load ==================
#Import CUR config and query strings
with open("config.yml", 'r') as ymlfile:
  cfg = yaml.safe_load(ymlfile)

#Import environment variable defined in Lambda, if it's not existed, use values defined in config.yml
region = os.environ.get('REGION')
if not region:
   region=cfg['Region']
curOutLoc = os.environ.get('CUR_OUTPUT_LOCATION')
if not curOutLoc:
  curOutLoc=cfg['CUR_Output_Location']
curDB = os.environ.get('CUR_DB')
if not curDB:
  curDB=cfg['CUR_DB']
curReportName = os.environ.get('CUR_REPORT_NAME')
if not curReportName:
  curReportName=cfg['CUR_Report_Name']
sender = os.environ.get('SENDER')
if not sender:
  sender=cfg['Sender']
recipient = os.environ.get('RECIPIENT')
if not recipient:
  recipient=cfg['Recipient']
subject = os.environ.get('SUBJECT')
if not subject:
  subject=cfg['Subject']
bodyText = os.environ.get('BODY_TEXT')
if not bodyText:
  bodyText=cfg['Body_Text']


#optional - match sheetname to add chart 
sheetNameMOM = "MoM_Inter_AZ_DT_Chart"
sheetNameMOM = "MoM_Out_DT_Chart"
# sheetNameWOW = "Inter_AZ_DT_WOW_Chart"

#temp path for converting csv to xlsx file, adding graph, and combining mulitple files to single one
tempPath = '/tmp'
#Expiration time for checking Athena query status, default value is 180 seconds
queryExpiration = 180


#Target bucket and key for CUR query results in s3
curBucket = curOutLoc.split('//')[1].split('/')[0]
curKeyPath = curOutLoc.split('//')[1].lstrip(curBucket).lstrip('/')

# print curBucket
# print curKeyPath


#Get current year, month and week 
curYear = datetime.datetime.now().year
curMonth = datetime.datetime.now().month
#if current month is Jan or Feb, set last year/month (and previous last month) correctly as report provides data in the past three months
if curMonth == 1:
  curOrLastYr = curYear-1
  lastYear = curYear-1
  lastMon = 12
  preLastMon = 11
elif curMonth == 2:
  curOrLastYr = curYear
  lastYear = curYear-1
  lastMon = 1
  preLastMon = 12
else:
  curOrLastYr = curYear
  lastYear = curYear
  lastMon = curMonth-1
  preLastMon = curMonth-2

#If you need to query CUR data at weekly basis. Uncomment below code and string replacement in qStrSub definition, to read current, last, previous last week 
# curWk = date.today().isocalendar()[1]
#if current week is 1 or 2, set last week and before to 52 or 51 (1 or 52)
# if curWk == 1:
#   lastWk = 52
#   preLastWk = 51
# elif curWk == 2:
#   lastWk = 1
#   preLastWk = 52
# else:
#   lastWk = curWk-1
#   preLastWk = curWk-2


#Define a dic list qStrList, and load all query strings into qStrList with the pair key (Name, queryString), also replace year/month in the strings
qStr = cfg['Query_String_List']
# print(qStr[0].values()[0])
qStrList = []
#Multiple charactors replacement in a string
def multReplace(string, substitutions):
  substrings = sorted(substitutions, key=len, reverse=True)
  regex = re.compile('|'.join(map(re.escape, substrings)))
  return regex.sub(lambda match: substitutions[match.group(0)], string)
qStrSub = {
  'CUR_DB': curDB,
  'CUR_YEAR': str(curYear),
  'CUR_MONTH': str(curMonth),
  # 'CUR_WEEK': str(curWk),
  'CUR_OR_LAST_YEAR': str(curOrLastYr),
  'LAST_YEAR': str(lastYear),
  'LAST_MONTH': str(lastMon),
  # 'LAST_WEEK': str(lastWk),
  'PRE_LAST_MONTH': str(preLastMon)
  # 'PRE_LAST_WEEK': str(preLastWk)
}
for i in range(len(qStr)):
  # print(list(qStr[i].values())[0])
  qString = multReplace(list(qStr[i].values())[0],qStrSub)
  qStrList.append({'name':list(qStr[i].keys())[0],'queryString':qString})
  


# print all query anme and string, for debug purpose
# for i in range(len(qStrList)):  
#   print(qStrList[i]['name'])
#   print(qStrList[i]['queryString'])




# =========== fuction definition ==================
#Query CUR using Athena 
#Run query string one by one, and storge query id as new key queryId in the qStrList
def queryCUR(queryList,targetLocation):
  client = boto3.client('athena')
  print("Starting query CUR ... ")
  for i in range(len(queryList)):
    resp = client.start_query_execution(
      QueryString=queryList[i]['queryString'],
      ResultConfiguration={
      'OutputLocation' : targetLocation
    })
    queryList[i]['queryId'] = resp['QueryExecutionId']
    print("Query "+queryList[i]['name']+' cost, queryId is '+queryList[i]['queryId'])


# Recursively load query status untill all query status is SUCCEEDED
def checkQueryExecution(queryIdList):
  client = boto3.client('athena')
  resp = client.batch_get_query_execution(QueryExecutionIds=queryIdList)
  query_execution = resp['QueryExecutions'] 
  unfinishedList = []
  for query in query_execution:
    print(query['QueryExecutionId'],query['Status']['State'])
    if query['Status']['State'] != 'SUCCEEDED':
      unfinishedList.append(query['QueryExecutionId'])
  if (len(unfinishedList) == 0):
    print("All queries are succeed")
    return "Succeed"
  else:
    time.sleep(10)
    checkQueryExecution(unfinishedList)



# Set signal alarm and wait all execution succeed or timeout
def waitQueryExecution(time,qList):
  queryIdList = []
  for i in range(len(qList)):
    queryIdList.append(qList[i]['queryId'])
  def myHandler(signum, frame):
    exit("Timeout - some queries are not succeed. exit!")
  signal.signal(signal.SIGALRM, myHandler)
  signal.alarm(time)
  print("Wait query execution, the expired time is "+str(time)+" seconds")
  checkQueryExecution(queryIdList)
  signal.alarm(0)


# Copy csv query results from s3 to local path
def cpResultsTolocal(bucketName, keyPath, queryList):
  os.chdir(tempPath)
  s3 = boto3.resource('s3')
  for i in range(len(queryList)): 
    print("Copy query result: s3://"+bucketName+"/"+keyPath+queryList[i]['queryId']+".csv")
    try:
      # os.chdir('/tmp')
      s3.Bucket(bucketName).download_file(keyPath+queryList[i]['queryId']+'.csv',queryList[i]['name']+'.csv')
    except botocore.exceptions.ClientError as e:
      if e.response['Error']['Code'] == "404":
        print("The target query result file does not exist.")
      else:
        raise

#Convert csv to xlsx files
def csvToXlsx(queryList):
  os.chdir(tempPath)
  for i in range(len(queryList)):
    csv = pd.read_csv(queryList[i]['name']+'.csv', encoding='utf-8')
    csv.to_excel(queryList[i]['name']+'.xlsx', sheet_name=queryList[i]['name'], index=False)

  

#Combine all xlsx files in to a single xlsx report file, and add chart for MOM and WOM sheets
def processExcel(reportName,queryList):
  os.chdir(tempPath)
  writer = pd.ExcelWriter(reportName, engine='xlsxwriter')
  for query in queryList:
    costDataFrame = pd.read_excel(query['name']+'.xlsx')
    costDataFrame.to_excel(writer, query['name'], index=False)
    #if query name defined in config.yml contains 'Chart', add chart for that sheet
    if "Chart" in query['name']:
      rowNum = len(costDataFrame)
      # print(query['name']+" row number is >>>>>>>>>>>"+str(rowNum))
      addChart(writer,query['name'],rowNum)
  writer.save()

#Add graph for monthly or weekly trend data
def addChart(writer,sheetName,rowIndex):
  workbook = writer.book
  worksheet = writer.sheets[sheetName]
  if sheetName == sheetNameMOM:
    print("Add graph for sheet "+sheetNameMOM)
    chart = workbook.add_chart({'type': 'column'})
    chart.add_series({
      'name':       'Usage Month Trend(GB)',
      'categories': [sheetName,1,1,rowIndex,1],
      'values':     [sheetName,1,2,rowIndex,2]
    })
    # Insert the chart into the worksheet.
    worksheet.insert_chart('C8', chart)
  # elif sheetName == sheetNameWOW:
  #   chart = workbook.add_chart({'type': 'column'})
  #   chart.add_series({
  #       'name':       'Usage Week Trend(GB)',
  #       'categories': [sheetName,1,2,rowIndex,2],
  #       'values':     [sheetName,1,3,rowIndex,3]
  #   })
  #   # Insert the chart into the worksheet.
  #   worksheet.insert_chart('D18', chart)
  elif sheetName == sheetNameWOW:
    chart = workbook.add_chart({'type': 'column'})
    chart.add_series({
        'name':       'Usage Week Trend(GB)',
        'categories': [sheetName,1,2,rowIndex,2],
        'values':     [sheetName,1,3,rowIndex,3]
    })
    # Insert the chart into the worksheet.
    worksheet.insert_chart('D18', chart)


# Send CUR report via SES
def sendReport(sesRegion,sesSub,sesSender,sesReceiver,sesReportName,sesBody):
  os.chdir(tempPath)
  print("Sending report via SES... ")
  client = boto3.client('ses',region_name=sesRegion)
  # Create a multipart/mixed parent container.
  msg = MIMEMultipart('mixed')
  # Add subject, from and to lines.
  msg['Subject'] = sesSub 
  msg['From'] = sesSender 
  msg['To'] = sesReceiver
  # Define the attachment part and encode it using MIMEApplication.
  att = MIMEApplication(open(sesReportName, 'rb').read())
  # Add a header to tell the email client to treat this part as an attachment,
  # and to give the attachment a name.
  att.add_header('Content-Disposition','attachment',filename=os.path.basename(sesReportName))
  # Add the attachment to the parent container.
  msg.attach(att)
  msg.attach(MIMEText(sesBody))
  #print(msg)
  try:
    #Provide the contents of the email.
    response = client.send_raw_email(
      Source=sesSender,
      Destinations=sesReceiver.split(','),
      RawMessage={
        'Data':msg.as_string()
      }
    )
    return response
  # Display an error if something goes wrong. 
  except ClientError as e:
    print(e.response['Error']['Message'])

  else:
    print("Email sent! Message ID:"),
    print(response['MessageId'])




# =========== Function Execution ==================
def lambda_handler(event, context):
  queryCUR(qStrList,curOutLoc)
  waitQueryExecution(queryExpiration,qStrList)
  cpResultsTolocal(curBucket,curKeyPath,qStrList)
  csvToXlsx(qStrList)
  processExcel(curReportName,qStrList)
# sendReport(region,subject,sender,recipient,curReportName,bodyText)
  response = sendReport(region,subject,sender,recipient,curReportName,bodyText)
  return response