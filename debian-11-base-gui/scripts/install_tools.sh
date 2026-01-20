#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
apt-get update -y
apt-get install  debconf-utils netcat vim wget git  -y


## install ubuntu-desktop gnome
echo "==> Installing ubuntu-desktop gnome "
apt-get update -y
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
apt-get install gnome/stable -y
systemctl set-default graphical.target

## install xrdp
echo "==> Installing xrdp"
apt-get update -y
apt-get install xrdp -y
systemctl restart xrdp
systemctl enable xrdp

# ## install docker
# echo "==> Installing docker"
# apt-get update -y
# apt-get  install     ca-certificates     curl     gnupg     lsb-release -y
# mkdir -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# apt-get  update -y
# apt-get  install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose -y
# systemctl restart docker
# systemctl enable docker
