# Pod Patterns in Kubernetes 

In this article, we discuss some pod patterns that are used in kubernetes. Kubernetes Pod is the basic building block of Kubernetes.combine containers into a single pod is called multi container pod.This makes communication between them faster and more secure, and they can share volume mounts and filesystems with each other.

There are three common design patterns and use-cases for combining multiple containers into a single pod. There are three widely recognised
- sidecar pattern
- adapter pattern 
- ambassador pattern
we will try to understand each pattern with and example

## Sidecar pattern

The sidecar container extends and works with the primary container. This pattern is best used when there is a clear difference between a primary container and any secondary tasks that need to be done for it.Your container works perfectly well without the sidecar, but with it, it can perform some extra functions. Some great examples are using a sidecar for monitoring and logging and adding an agent for these purposes.

For example, a web server container (a primary application) that needs to have its logs parsed and forwarded to log storage (a secondary task) may use a sidecar container that takes care of the log forwarding. This same sidecar container can also be used in other places in the stack to forward logs for other web servers or even other applications.

For the demo, let’s look at a sidecar pattern with an application generating logs at a particular file path, where the sidecar pushes the records to the nginx HTML directory for users to view.

```sh
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  volumes:
  - name: logs 
    emptyDir: {}
  containers:
  - name: app-container
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "while true; do date >> /var/log/app.log; sleep 2;done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: log-exporter-sidecar
    image: nginx
    ports:
      - containerPort: 80
    volumeMounts:
    - name: logs
      mountPath: /usr/share/nginx/html
```

So, if you look at the manifest you’ll see we have two containers: app-container and log-exporter-sidecar. The app-container continuously streams logs to /var/log/app.log, and the sidecar container mounts the logs to the nginx HTML directory. This allows anyone to visualise the logs using a web browser.

Create the Pod using sidecar-pod.yaml file
```sh
kubectl apply -f sidecar-pod.yaml
```
check status of pod 
```sh
kubectl get pod 
```
pod image 1

here you can see that pod is running now when you apply the manifest and run a port-forward on port 80, you should be able to access the logs using a browser.

kubectl port-forward sidecar-pod 80:80

output image 

## Ambassador pattern

Also known as Proxy pattern. The ambassador pattern is another way to run additional services together with your main application container but it does so through a proxy. The primary goal of an ambassador container is to simplify the access of external services for the main application where the ambassador container acts as a service discovery layer.

One of the best use-cases for the ambassador pattern is for providing access to a database. When developing locally, you probably want to use your local database, while your test and production deployments want different databases again.

For the demo, we will use a simple NGINX config that acts as a TCP proxy to example.com. That should also work for databases and other back ends.

```sh
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pod
  labels:
    app: ambassador-app
spec:
  volumes:
  - name: shared
    emptyDir: {}
  containers:
  - name: app-container-poller
    image: yauritux/busybox-curl
    command: ["/bin/sh"]
    args: ["-c", "while true; do curl 127.0.0.1:81 > /usr/share/nginx/html/index.html; sleep 10; done"]
    volumeMounts:
    - name: shared
      mountPath: /usr/share/nginx/html
  - name: app-container-server
    image: nginx
    ports:
      - containerPort: 80
    volumeMounts:
    - name: shared
      mountPath: /usr/share/nginx/html
  - name: ambassador-container
    image: bharamicrosystems/nginx-forward-proxy
    ports:
      - containerPort: 81
```


If you look carefully in the manifest YAML, you will find there are three containers. The app-container-poller continuously calls http://localhost:81 and sends the content to /usr/share/nginx/html/index.html.

Create the Pod using sidecar-pod.yaml file
```sh
kubectl apply -f ambassador-pod.yaml
```
check status of pod 
```sh
kubectl get pod 
```
pod image 3



## Adapter pattern

The adapter pattern is used to standardize and normalize application output or monitoring data for aggregation.For example, an adapter container could expose a standardized monitoring interface to your application even though the application does not implement it in a standard way. The adapter container takes care of converting the output into what is acceptable at the cluster level.

Now, you have a centralised logging system that accepts logs in a particular format only. What can you do in such a situation? Well, you can either change the source code of each application to output a standard log format or use an adapter to standardise the logs before sending it to your central server. That’s where the adapter pattern comes in.

For our hands-on exercise, let’s consider that an application that outputs logs in a particular format, that we want to change to something standard.

```sh
apiVersion: v1
kind: Pod
metadata:
  name: adapter-pod
  labels:
    app: adapter-app
spec:
  volumes:
  - name: logs
    emptyDir: {}
  containers:
  - name: app-container
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "while true; do date >> /var/log/app.log; sleep 2;done"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
  - name: log-adapter
    image: alpine
    command: ["/bin/sh"]
    args: ["-c", "tail -f /var/log/app.log|sed -e 's/^/Date /' > /var/log/out.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log
```

In the manifest, we have an app-container that outputs a stream of dates to a log file. The log-adapter container adds a Date prefix in front. Yes, it’s a very rudimentary example, but enough to get how the adapter works.

Create the Pod using sidecar-pod.yaml file
```sh
kubectl apply -f ambassador-pod.yaml
```
check status of pod 
```sh
kubectl get pod 
```
pod image 4

# Conclusion

This article we had a look at pod patterns and multi-container pod that are used in kubernetes.Multi-container pods exist for a good reason in Kubernetes.


# About Author

The author, [Ninad Samudre](https://www.linkedin.com/in/ninad-samudre-19439b1a5/), is The Cloud Application Manager @ Brain Upgrade where he manage IoT-based Fleet Management Platform that runs on a Kubernetes Cluster on AWS Amazon.

# About Brain Upgrade Academy

We, at Brain Upgrade, offer Kubernetes Consulting services to our clients including Up Skilling (training) of clients teams thus facilitate efficient utilization of Kubernetes Platform.  To know more on the Kubernetes please visit [www.brainupgrade.in/blog](www.brainupgrade.in/blog) and register on [www.brainupgrade.in/enroll](www.brainupgrade.in/enroll) to equip yourself with Kubernetes skills.

# Why Brain Upgrade

We at Brain Upgrade, partner with our customers in the digital transformation of their businesses by providing: 

Technology Consulting in product development, IoT, DevOps, Cloud, Containerization, Big Data Analysis with a heavy focus on Open source technologies. 
Training the IT workforce on the latest cloud technologies such as Kubernetes, Docker, AI, ML, etc. 

You may want to register for the upcoming trainings on [https://brainupgrade.in/enroll](https://brainupgrade.in/enroll)