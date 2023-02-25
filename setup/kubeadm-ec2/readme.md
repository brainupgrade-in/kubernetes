# Multi-node kubeadm cluster (1 master, 2 workers) using virtualbox & vagrant
- Install virtualbox (https://www.virtualbox.org/wiki/Downloads) (PRE-REQUISITE)
- Install Vagrant (https://developer.hashicorp.com/vagrant/downloads) (PRE-REQUISITE)
- Copy Vagrantfile and common.sh from this git folder to your computer say /tmp/kubeadm
- `wget https://raw.githubusercontent.com/brainupgrade-in/kubernetes/main/setup/kubeadm/Vagrantfile`
- `wget https://raw.githubusercontent.com/brainupgrade-in/kubernetes/main/setup/kubeadm/common.sh`
- Open terminal say Tab1 and `cd` where you copied above files and Run `vagrant up` 
- ssh into master `vagrant ssh master`
- Launch cluster by initializing master node
`kubeadm init --apiserver-advertise-address 10.0.0.10 --pod-network-cidr 192.168.0.1/16` 
- Install CNI `curl https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml -O && kubectl apply -f calico.yaml`
- Get join command using this command on master `kubeadm token create --print-join-command`
- Launch one more terminal tab say Tab2 & copy join command and ssh into node01  `vagrant ssh node01`
- Paste the join command & hit Enter. Similarly, paste this join command on node02 and hit Enter

# Enable ingress - master node 
- Install ingress from nginx `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/baremetal/deploy.yaml`
- Install nginx using `sudo apt install nginx` and then create conf `sudo vi /etc/nginx/sites-available/kubernetes.conf` with below content
```
upstream kubernetes {
  server        10.0.0.10:<nginx ingress svc port mapped for 80>;
}
server {
  listen        80;
  server_name   *.brainupgrade.in;

  location / {
                proxy_http_version 1.1;
                proxy_connect_timeout 60s;
                proxy_read_timeout 60s;
                proxy_send_timeout 60s;
                client_max_body_size 1m;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Port $server_port;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_buffering on;
                proxy_pass  http://kubernetes;
  }
}
```
- Enable the app URL `sudo ln -s /etc/nginx/sites-available/kubernetes.conf /etc/nginx/sites-enabled/`
- Restart / reload nginx `sudo systemctl restart nginx`
# Test 
- Deploy hello app `kubectl create deploy hello --image brainupgrade/hello`
- Expose the app as service `kubectl expose deploy hello --port 80 --target-port 8080`
- Create ingress for this app `kubectl create ingress hello --rule="hello.brainupgrade.in/*=hello:80" --class nginx`
- Add this line `10.0.0.10 hello.brainupgrade.in` to your /etc/hosts file on your host computer 
- Browse http://hello.brainupgrade.in on your host computer to verify app output

