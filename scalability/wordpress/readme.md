Use vagrant machine 4 core 4gb
Install kind  cluster 1 m 3 n
Enable storage
Install wp
Setup kubernetes cluster using kubeadm - master 1 and 2 workers
Refer the vagrant scripts -  https://github.com/brainupgrade-in/dockerk8s/tree/main/misc/vagrant
Metal LB Ingress load balancer - 
Deploy wordpress using host storage

kubectl expose deploy mariadb --port 3306 --target-port 3306
kubectl create ingress wordpress --rule="test-wordpress.com/=wordpress:80" --class nginx
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml