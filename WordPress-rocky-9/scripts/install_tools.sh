#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
yum update -y
yum install net-tools nc vim wget git mlocate  epel-release unzip  -y
yum install -y yum-utils 

#Install httpd, php, mariadb
echo "==> Install httpd, php, mariadb"
dnf -y install mariadb-server httpd
dnf install -y php php-zip php-intl php-mysqlnd php-dom php-simplexml php-xml php-xmlreader php-curl php-exif php-ftp php-gd php-iconv php-json php-mbstring php-posix php-sockets php-tokenizer



## install  gnome
echo "==> Installing  gnome "
dnf install gdm gnome-shell gnome-terminal -y
systemctl enable gdm
systemctl set-default graphical

## install xrdp
echo "==> Installing xrdp"
yum install xrdp firefox -y
systemctl restart xrdp
systemctl enable xrdp
# systemctl start firewalld
# systemctl enable firewalld
# firewall-cmd --permanent --add-port=3389/tcp
# firewall-cmd --reload
