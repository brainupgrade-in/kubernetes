FROM openjdk:11-jdk

RUN apt-get update -y && apt-get install -y curl maven sudo

# install docker cli
RUN mkdir -p /tmp/_install && cd /tmp/_install && wget https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && tar -xvzf docker-latest.tgz && cd docker && cp docker /usr/bin/docker && rm -rf /tmp/_install
RUN chmod +x /usr/bin/docker
# add jenkins to docker group
RUN groupadd -g 999 docker
#RUN usermod -a -G docker jenkins

ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group} 
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}
RUN usermod -aG sudo ${user}

ARG VERSION=3.20
ARG AGENT_WORKDIR=/home/${user}/agent

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

#docker compose cli
RUN curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod 777 /usr/local/bin/jenkins-slave

RUN echo 'jenkins ALL=(ALL) NOPASSWD:ALL'| sudo EDITOR='tee -a' visudo

# below is to ensure jenkins to have access to docker commands
RUN usermod -aG docker ${user}
RUN exec newgrp docker 
RUN exec su -l ${user}

# Comment below  otherwise agent will not run saying /home/jenkins/agent directory does not have appropriate RWX permissions
USER ${user}  

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

# VOLUME /home/${user}/.jenkins
# VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}


# RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
# RUN chmod +x ./kubectl


ENTRYPOINT ["/usr/local/bin/jenkins-slave"]