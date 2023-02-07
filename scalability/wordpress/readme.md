# Install metrics server using Helm
## Install helm
`curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash`
## Add bitnami repo and install metrics server
`helm repo add bitnami https://charts.bitnami.com/bitnami`

`helm install metrics bitnami/metrics-server`

`helm upgrade --namespace default metrics bitnami/metrics-server --set apiService.create=true`

`kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"`
## Update metrics server to run in local kubeadm cluster
Metrics
kubectl edit deploy metrics-metrics-server
        command:
        - metrics-server
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP
# Deploy wordpress app
`kubectl apply -k .`
## Define resources
`kubectl set resources deploy wordpress --requests=cpu=50m,memory=100Mi –limits=cpu=200m,memory=300Mi`
## Enable Horizontal scaling
`kubectl autoscale --min 1 --max 5 deploy wordpress --cpu-percent 50`
# Apache Bench
If using ubuntu as host os, then use below command else download from Apache bench site
`sudo apt-get install apache2-utils`
# Troubleshooting
## Coredns
If wordpress is unable to connect to the database, then restart coredns deployment

`kubectl rollout restart deploy coredns -n kube-system`