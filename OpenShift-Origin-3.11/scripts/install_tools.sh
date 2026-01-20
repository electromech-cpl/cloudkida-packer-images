#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
yum update -y
yum install net-tools netcat vim wget git mlocate docker -y
usermod -aG docker ec2-user
systemctl restart docker
systemctl enable docker

## install amazonlinux-desktop gnome
echo "==> Installing amazonlinux-desktop gnome "
# apt update -y
# apt install ubuntu-desktop -y
amazon-linux-extras install mate-desktop1.x
amazon-linux-extras install epel -y
bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'


## install amazonlinux-desktop firefox
echo "==> Installing amazonlinux-desktop firefox "
wget https://download-installer.cdn.mozilla.net/pub/firefox/releases/109.0.1/linux-x86_64/en-GB/firefox-109.0.1.tar.bz2
tar xjf firefox-*.tar.bz2
mv firefox /opt
ln -s /opt/firefox/firefox /usr/local/bin/firefox
wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications
rm -rf firefox-*.tar.bz2

## install xrdp
echo "==> Installing xrdp"
yum install xrdp -y
systemctl restart xrdp
systemctl enable xrdp


