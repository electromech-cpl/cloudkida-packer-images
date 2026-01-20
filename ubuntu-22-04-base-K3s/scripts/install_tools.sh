#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
apt update -y
apt-get install net-tools netcat vim wget git mlocate -y


## Install Docker
echo "==> Install Docker"
apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update
apt-get install docker-ce -y
systemctl start docker
systemctl enable docker