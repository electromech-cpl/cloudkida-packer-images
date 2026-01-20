#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
yum update -y
yum install net-tools nc vim wget git mlocate -y


## install  gnome
echo "==> Installing  gnome "
yum group install "Server with GUI" -y
systemctl set-default graphical

## install xrdp
echo "==> Installing xrdp"
yum install xrdp -y
systemctl restart xrdp
systemctl enable xrdp
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=3389/tcp
firewall-cmd --reload
