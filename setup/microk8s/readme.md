# Kubernetes k8s cluster using microk8s
- Install virtualbox (https://www.virtualbox.org/wiki/Downloads) (PRE-REQUISITE)
- Install Vagrant (https://developer.hashicorp.com/vagrant/downloads) (PRE-REQUISITE)
- Get Ubuntu Virtual Machine `mkdir /tmp/microk8s -p && cd /tmp/microk8s && vagrant init bento/ubuntu-22.04`
- Update Vagrantfile by changing vb.memory to "4096" and then run `vagrant up`
- Login into vagrant ubuntu box `vagrant ssh default`
