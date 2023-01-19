# Kubernetes k8s cluster using microk8s
- Install virtualbox (https://www.virtualbox.org/wiki/Downloads) (PRE-REQUISITE)
- Install Vagrant (https://developer.hashicorp.com/vagrant/downloads) (PRE-REQUISITE)
- Get Ubuntu Virtual Machine `mkdir /tmp/microk8s -p && cd /tmp/microk8s && vagrant init bento/ubuntu-22.04`
- Update Vagrantfile by changing vb.memory to "4096" and then run `vagrant up`
- Login into vagrant ubuntu box `vagrant ssh default`
- Download & launch microk8s cluster `sudo snap install microk8s --classic`
- Add user to microk8s `sudo usermod -a -G microk8s vagrant` & reload user group `newgrp microk8s`
- Set alias `alias k="microk8s kubectl"` and `alias kubectl="microk8s kubectl"`
- Verify if cluster is ready `k get nodes`

# Enable ingress - master node 
- Install ingress from nginx `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/baremetal/deploy.yaml`

# Nginx to route request from vagrant host to k8s cluster via ingress controller
- Install nginx using `sudo apt update && sudo apt install nginx -y` and then create conf `sudo vi /etc/nginx/sites-available/kubernetes.conf` with below content
```
upstream kubernetes {
  server        10.0.2.15:<nginx ingress svc port mapped for 80>;
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
- Add `<master node ip> hello.brainupgrade.in` to your vagrant host file /etc/hosts
- `curl http://hello.brainupgrade.in` on your vagrant host to verify app output
