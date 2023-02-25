#!/bin/bash

# CNI - Calico
curl https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml -O && kubectl apply -f calico.yaml

# Ingress - Nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/baremetal/deploy.yaml

# HELM
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Metrics Server
helm repo add bitnami https://charts.bitnami.com/bitnami

helm install metrics bitnami/metrics-server

helm upgrade --namespace default metrics bitnami/metrics-server --set apiService.create=true

# Modify the deployment & add these to metrics-server command   
# --kubelet-insecure-tls 
# --kubelet-preferred-address-types=InternalIP

# Prometheus, Graphana, FluentD...