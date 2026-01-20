#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
yum update -y
yum install net-tools nc vim wget git mlocate  epel-release -y
yum install -y yum-utils 
# yum-config-manager \
#     --add-repo \
#  https://download.docker.com/linux/centos/docker-ce.repo
# yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
# usermod -aG docker rocky
# systemctl restart docker
# systemctl enable docker


## install  gnome
echo "==> Installing  gnome "
dnf group install "Server with GUI" -y
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
