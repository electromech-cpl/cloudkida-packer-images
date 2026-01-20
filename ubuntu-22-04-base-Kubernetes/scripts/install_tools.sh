#!/bin/bash -eux

## install basic cmd
echo "==> Installing basic cmd"
apt update -y
apt install net-tools netcat vim wget git mlocate -y
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

## Install kubelet, kubeadm and kubectl
echo "==> Install kubelet, kubeadm and kubectl"
apt install curl apt-transport-https -y
curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install wget curl vim git kubelet kubeadm kubectl bash-completion  -y
apt-mark hold kubelet kubeadm kubectl

## Load the  kernel modules
echo "==> Load the  kernel modules"
modprobe overlay
modprobe br_netfilter

## Add some settings to sysctl
echo "==> Add some settings to sysctl"
tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

## install Docker runtime
echo "==> Installing Docker runtime"
apt update
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io
# sudo apt install -y containerd.io docker-ce docker-ce-cli
# Create required directories
# sudo mkdir -p /etc/systemd/system/docker.service.d

# # Create daemon json config file
# sudo tee /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2"
# }
# EOF

# Start and enable Services
# sudo systemctl daemon-reload 
# sudo systemctl restart docker
# sudo systemctl enable docker

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Configure persistent loading of modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Ensure you load modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart containerd
sudo systemctl enable containerd

## Pull container images
echo "==> Pull container images"
lsmod | grep br_netfilter
systemctl enable kubelet
systemctl restart kubelet
kubeadm config images pull

## Install Helm CMD
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -rf ./get_helm.sh