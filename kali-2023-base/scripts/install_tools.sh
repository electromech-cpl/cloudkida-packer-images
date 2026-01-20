#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
apt update -y
apt install net-tools  vim wget git mlocate -y


## install ubuntu-desktop gnome
# echo "==> Installing ubuntu-desktop gnome "
# apt update -y
# apt install ubuntu-desktop -y


## install xrdp
# echo "==> Installing xrdp"
# apt update -y
# apt install xrdp -y

## install basic cmd
echo "==> Installing meta kali"
apt update -y
apt install -y kali-tools-information-gathering 
apt install -y kali-tools-vulnerability 
apt install -y kali-tools-web 
apt install -y kali-tools-database
apt install -y kali-tools-passwords
apt install -y kali-tools-reverse-engineering
apt install -y kali-tools-exploitation
apt install -y kali-tools-social-engineering
apt install -y kali-tools-sniffing-spoofing
apt install -y kali-tools-post-exploitation
apt install -y kali-tools-forensics
apt install -y kali-tools-reporting


