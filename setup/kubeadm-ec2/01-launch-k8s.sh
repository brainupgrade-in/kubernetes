#!/bin/bash

sudo kubeadm init  --pod-network-cidr 192.168.0.1/16 --kubernetes-version=1.25.6