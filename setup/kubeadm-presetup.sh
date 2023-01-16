#!/bin/bash

# Networking and base os setup and installation of basic os libraries
# disable swap 
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo tee /etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# Reload sysctl
sudo sysctl --system

sudo apt-get update -y 
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release gnupg2 software-properties-common

sudo lsmod | grep br_netfilter

# CRI implementation and other related setup
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

# Configure containerd and start service
sudo mkdir -p /etc/containerd
sudo containerd config default>/etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
sudo systemctl status  containerd

# Installation of kubeadm, kubelet and kubectl 
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
#Specify a version
sudo apt-get install -y kubelet=1.25.0-00 kubectl=1.25.0-00 kubeadm=1.25.0-00 

sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet

IPADDR=$(wget -qO-  http://checkip.amazonaws.com)

sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl start kubelet
#sudo kubeadm init  --pod-network-cidr=192.168.0.0/16  

# curl https://docs.projectcalico.org/manifests/calico.yaml -O
# kubectl apply -f calico.yaml