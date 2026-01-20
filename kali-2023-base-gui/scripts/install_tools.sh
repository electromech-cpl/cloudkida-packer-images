#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
apt update -y
apt install net-tools  vim wget git mlocate -y


## install ubuntu-desktop gnome
echo "==> Installing ubuntu-desktop gnome "
apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y kali-desktop-gnome gdm3


## install xrdp
echo "==> Installing xrdp"
apt update -y
apt install xrdp -y

systemctl restart xrdp
systemctl enable xrdp

## install basic cmd
echo "==> Installing meta kali"

apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y kali-tools-information-gathering  kali-tools-vulnerability  kali-tools-web kali-tools-database kali-tools-passwords kali-tools-reverse-engineering kali-tools-exploitation kali-tools-social-engineering kali-tools-sniffing-spoofing kali-tools-post-exploitation kali-tools-forensics kali-tools-reporting 