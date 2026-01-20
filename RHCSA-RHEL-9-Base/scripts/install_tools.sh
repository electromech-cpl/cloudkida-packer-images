#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
yum update -y
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
yum install net-tools nc vim wget git mlocate  -y
yum install -y yum-utils sysstat nmap  httpd  cronie tuned lvm2 stratisd stratis-cli chrony  bind-utils nfs-utils nfs4-acl-tools autofs mod_ssl cockpit container-tools 
dnf group install -y "Security Tools"
  

## install  gnome
# echo "==> Installing  gnome "
# dnf group install "Server with GUI" -y
# systemctl set-default graphical

## install xrdp
echo "==> Installing xrdp"
# yum install xrdp -y
# systemctl restart xrdp
# systemctl enable xrdp
# systemctl start firewalld
# systemctl enable firewalld
# firewall-cmd --permanent --add-port=3389/tcp
# firewall-cmd --reload
