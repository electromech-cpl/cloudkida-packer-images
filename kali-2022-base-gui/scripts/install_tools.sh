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


