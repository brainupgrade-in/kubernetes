# Setup minikube cluster using vagrant & virtualbox
- Install virtualbox (https://www.virtualbox.org/wiki/Downloads) (PRE-REQUISITE)
- Install Vagrant (https://developer.hashicorp.com/vagrant/downloads) (PRE-REQUISITE)
- Get Ubuntu Virtual Machine `mkdir /tmp/minikube -p && cd /tmp/minikube && vagrant init bento/ubuntu-22.04`
- Update Vagrantfile by changing vb.memory to "4096" and then run `vagrant up`
- Login into vagrant ubuntu box `vagrant ssh default`
- Download minikube `curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64`
- Install minikube `sudo install minikube-linux-amd64 /usr/local/bin/minikube`
- Install docker `sudo apt update && sudo apt install docker.io`
- Add user to docker group `sudo usermod -aG docker $USER && newgrp docker`
- Start minikube `minikube start --driver docker `
- Enable Ingress on minikube `minikube addons enable ingress`
# Route requests from Vagrant host to minikube master
- Install nginx using `sudo apt install nginx` and then create conf `sudo vi /etc/nginx/sites-available/kubernetes.conf` with below content
```
upstream kubernetes {
  server        <minikube ip>:<nginx ingress svc port mapped for 80>;
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
- Set alias `alias k="minikube kubectl --"`
- Deploy hello app `kubectl create deploy hello --image brainupgrade/hello`
- Expose the app as service `kubectl expose deploy hello --port 80 --target-port 8080`
- Create ingress for this app `kubectl create ingress hello --rule="hello.brainupgrade.in/*=hello:80" --class nginx`
- `curl http://hello.brainupgrade.in` on your vagrant host to verify app output
