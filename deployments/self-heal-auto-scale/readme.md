# Build Self-healing applications that scale automatically using Kubernetes

Spending sleep-less nights to troubleshoot applications?  even wondering if **Can one build self-healing applications at all?**...  This article helps you not only build self-healing applications but also scale them automatically based on your production workload.

## What is Self-healing?

In software systems, the self-healing terms describes any application or system that can restore iteself without human intervention after discovering that is not working correctly.

To make applications self-healing in nature, focus needs to be given on application design as well as the runtime infrastructure.

In general, there are three self-healing layers in the context of container based deployments.
1. Application Level
2. Kubernetes Level
3. Infrastructure Level

From the deployment / runtime infrastructure perspective, we will look at how Kubernetes helps in achieving self-healing.

### Application Level

By adopting best software development practices like Error handling, Retry Management, Loosely coupled components etc., we can cover the application specific design aspects of self-healing.

In this post, we will focus more on other two levels.

### Kubernetes Level

Kubernetes provides restart policy as part of application Deployment defintion. 

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: brainupgrade-app
  namespace: brainupgrade
spec:
  template:
    spec:
...    
      restartPolicy: Always
```      

When **restartPolicy** is specified as Always, the Kubernetes ensures that the application instances are restarted whenever they become unavailable due to reasons for example: OOM (OutOfMemory) Error, Node failure, application exiting with non-zero status or killed by the system.

In case, applicaiton becomes non-responsive because of its internal process getting stuck then Kubernetes provides LivenessProbe which can be used as a mechanism to achieve self-healing.  See below

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: brainupgrade-app
  namespace: brainupgrade
spec:
...
  template:
    spec:
      containers:
      - image: brainupgrade/weather:monolith
        name: iot-platform
...        
        livenessProbe:
          httpGet: 
            path: /favicon.ico
            port: 80
          periodSeconds: 10
          failureThreshold: 6          
```

What above snippet directs the Kubernetes to do is: Check for the resource on 80 using httpGet every 10 seconds and if check fails 6 consecutive times then restart the applicaiton instance.

### Infrastructure Level

Some of the infrastructure resources that your applicaiton may require are:
1. Nodes to run app instances on
2. Storage (File, Database etc)
3. Network
...

Detecting impaired nodes and replacing them with the new ones can be achieved using cloud providers auto-scaling feature which we will cover in the next section.  Building self-healing for resources like Storage and Network is outside the scope of this post.

## Autoscale - App & Infrastructure

Autoscaling is required on both fronts: 1. Application and 2. Infrastructure

### Autoscaling app instances

To achieve autoscaling on applicaiton front, we can take below steps:

Install Metrics Server using helm

```
helm install stable/metrics-server  --name metrics-server --namespace kube-system
```

and then issue autoscale command like below

```
kubectl autoscale deploy <name of app> --min=<number of instances>  --max=<number of instances>
```

Above command launches ```hpa``` (Horizontal Pod Autoscaler) that automatically chooses and sets the number of pods that run in a kubernetes cluster based on the  cpu usage for example, if CPU usage threshold (default 80%) is crossed then new instance is created.

### Autoscaling Nodes - Infrastructure

When it comes to scaling nodes based on the cluster load, we can use Cloud provider's autoscaling feature.  Below example assumes that cloud  provider is AWS and KOPS is used to manage the cluster.

Whichever instance group that you would like to define the autoscaling, you can add below snippet to the InstanceGroup spec.

```
...
kind: InstanceGroup
...
spec:
  cloudLabels:
    service: k8s_node
    k8s.io/cluster-autoscaler/enabled: ""
    k8s.io/cluster-autoscaler/<name of the cluster>: ""
  maxSize: 10
  minSize: 2
...
```

Then add autoscaling policies by editing your Cluster spec

```
...
kind: Cluster
...
spec:
  additionalPolicies:
    node: |
      [
        {
          "Effect": "Allow",
          "Action": [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup",
            "autoscaling:DescribeTags"
          ],
          "Resource": "*"
        }
      ]
...
```

Apply the changes to the cluster

```
kops update cluster --name <name of cluster> --state s3://<s3 bucket url>
kops rolling-update cluster --name <name of cluster> --state s3://<s3 bucket url> --yes
```

Once done, apply create appropriate roles and permissions including launching scaling agent.  See below:

```
kubectl apply -f [autoscaler-autodiscover.yaml](./autoscaler-autodiscover.yaml)
```

Please do modify the yaml by replacing name of your cluster on line 157

## Conclusion

In this article, we have seen the options provided by Kubernetes to build self-healing applications besides learnt to scale not only the application but also the nodes on which applications run.

#### Tags: #devops #kubernetes #selfheal #autoscale #aws #kops

# About The Author

The author, [Rajesh G](https://www.linkedin.com/in/rajesh-g-b48495/), is The Chief Architect @ Brain Upgrade Academy where he has designed the IoT-based Fleet Management Platform that runs on a Kubernetes Cluster on AWS Amazon.  He is also a certified Kubernetes Administrator and TOGAF certified Enterprise Architect.
Rajesh led various digital transformation initiatives for Fortune 500 FinTech companies. Over the last 20+ years, he has been part of many successful technology startups.

# About Brain Upgrade Academy

We, at Brain Upgrade, offer Kubernetes Consulting services to our clients including Up Skilling (training) of clients teams thus facilitate efficient utilization of Kubernetes Platform.  To know more on the Kubernetes please visit [www.brainupgrade.in/blog](www.brainupgrade.in/blog) and register on [www.brainupgrade.in/enroll](www.brainupgrade.in/enroll) to equip yourself with Kubernetes skills.

# Why Brain Upgrade

We at Brain Upgrade, partner with our customers in the digital transformation of their businesses by providing: 

Technology Consulting in product development, IoT, DevOps, Cloud, Containerization, Big Data Analysis with a heavy focus on Open source technologies. 
Training the IT workforce on the latest cloud technologies such as Kubernetes, Docker, AI, ML, etc. 

You may want to register for the upcoming trainings on [https://brainupgrade.in/enroll](https://brainupgrade.in/enroll)