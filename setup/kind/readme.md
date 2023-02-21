# Multi-node kubeadm cluster (1 master, 2 workers) using kind
## Pre-requisites
Host OS - Ubuntu 22.04 or higher

- Install docker

```
sudo apt-get update && sudo apt-get install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```
Restart the system

- Install kind
```
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
- Get cluster config file

`wget https://raw.githubusercontent.com/brainupgrade-in/kubernetes/main/setup/kind/cluster.yaml`
- Launch 3 node cluster

`kind create cluster --name k8s --config cluster.yaml`
- Set alias 

`echo "alias k=kubectl" >> ~/.bash_aliases`
`source ~/.bash_aliases`

# Test 
- Deploy hello app 

`kubectl create deploy hello --image brainupgrade/hello --replicas 2`
- Expose the app as service 

`kubectl expose deploy hello --port 80 --target-port 8080`
- Check if two pods are running on worker nodes using


`kubectl get pods -owide`

