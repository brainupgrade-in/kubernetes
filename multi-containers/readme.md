## Multi-container pods in Kubernetes and communication between them using a shared Volume

In this Blog I will show How to create Multi-container pods in Kubernetes and establish communication between them using a shared Volume

# You need a few things.

1.An existing Kubernetes Cluster or minikube.
2.kubectl binary locally installed.

# Creating a Pod that runs two Containers 

In this blog, we create a Pod that runs two Containers. The two containers share a Volume that they can use to communicate. Here is the configuration file for the Pod:

two-container-pod.yaml

```sh
apiVersion: v1
kind: Pod
metadata:
  name: two-container-pod
spec:

  restartPolicy: Never

  volumes:
  - name: shared-data
    emptyDir: {}

  containers:

  - name: nginx-container
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html

  - name: debian-container
    image: debian
    volumeMounts:
    - name: shared-data
      mountPath: /pod-data
    command: ["/bin/sh"]
    args: ["-c", "echo welcome to brainupgrade > /pod-data/index.html"]
```

![Pod](./multi-containers/pod-created.png)

Having multiple containers in a single Pod makes it relatively straightforward for them to communicate with each other. They can do this using Shared volumes.

In this example, we define a volume named shared-data. Its type is emptyDir, which means that the volume is first created when a Pod is assigned to a node, and exists as long as that Pod is running on that node.As the name says, it is initially empty. The 1st container runs nginx server and has the shared volume mounted to the directory /usr/share/nginx/html.The 2nd container uses the Debian image and has the shared volume mounted to the directory /pod-data. 

Notice that the second container writes the index.html file in the root directory of the nginx server.

Create the Pod and the two Containers:
```sh
kubectl apply -f two-container-pod.yaml
```
View information about the Pod and the Containers:
```sh
kubectl get pod two-container-pod --output=yaml
```
Here is a portion of the output:

![Container](./multi-containers/Container-terminate.png)

You can see that the debian Container has terminated, and the nginx Container is still running.

Get a shell to nginx Container:
```sh
kubectl exec -it two-container-pod -c nginx-container -- /bin/bash
```
In your shell, verify that nginx is running:
```sh
root@two-containers:/# apt-get update
root@two-containers:/# apt-get install curl procps
root@two-containers:/# ps aux
```
The output is similar to this:

Recall that the debian Container created the index.html file in the nginx root directory. Use curl to send a GET request to the nginx server:
```sh
root@two-containers:/# curl localhost
```
The output shows that nginx serves a web page written by the debian container:

welcome to brainupgrade

![output](./multi-containers/Output.png)