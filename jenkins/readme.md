# Automated CI & CD - Jenkins on Kubernetes

## Jenkins Master Node
Jenkins master uses the image brainupgrade/jenkins:2.274jdk11x
This image has many plugins required for smooth CD on kubernetes.  To know the image content, Dockerfile (./master/Dockerfile) is kept here

## Jenkins Slave Node

Jenkins slave uses the image brainupgrade/jenkins-slave:5.0.0
This image is based on openjdk11 containing maven, docker and kubectl runtime so that spring boot 
project can be checked out, maven built, docker imaged and kuberneted deployed.