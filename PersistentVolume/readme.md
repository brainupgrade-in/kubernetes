# Configuring a Pod to Use a PersistentVolume for Storage in Kubernetes

In this blog I will show how to Configuring a pod to use a PersistentVolume for Storage in Kubernetes. We will understand this by creating a PersistentVolumeClaim that is automatically bound to a suitable PersistentVolume. And we will also create a Pod that uses the PersistentVolumeClaim for storage.


## You need a few things.

- An existing Kubernetes Cluster or minikube.
- kubectl binary locally installed.
- Familiarize yourself with the material in Persistent Volumes.

## Create an index.html file on your Node

Open a shell to the single Node in your cluster. if you are using Minikube, you can open a shell to your Node by entering  
```sh
 minikube ssh 
 ```

 In your shell on that Node, create a /mnt/data directory by assuming that your Node uses "sudo" to run commands as the superuser
```sh
sudo mkdir /mnt/data
 ```

 In the /mnt/data directory, create an index.html file:

  ```sh
sudo sh -c "echo 'Hello from BrainUpgrade Academy' > /mnt/data/index.html"
 ```

 Test that the index.html file exists by following command :
```sh
cat /mnt/data/index.html
 ```

 The output should be:

 ```sh
Hello from BrainUpgrade Academy
 ```

## PersistentVolume

A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by server/storage/cluster administrator or dynamically provisioned using Storage Classes. It is a resource in the cluster just like node.

In this blog, we will create a hostPath PersistentVolume. Kubernetes supports hostPath for development and testing on a single-node cluster. A hostPath PersistentVolume uses a file or directory on the Node to emulate network-attached storage.

Here is the configuration file for the hostPath PersistentVolume:

task-pv-volume.yaml

 ```sh
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
 ```

The configuration file specifies that the volume is at /mnt/data on the cluster's Node. The configuration also specifies a size of 10 gibibytes and an access mode of ReadWriteOnce, which means the volume can be mounted as read-write by a single Node. It defines the StorageClass name manual for the PersistentVolume, which will be used to bind PersistentVolumeClaim requests to this PersistentVolume.

Now Create the PersistentVolume: