FROM centos:7

ENV LANG=en_US.UTF-8
ENV AWSCLI2_VERSION 2.1.37
WORKDIR /root

RUN rpm --import https://packages.confluent.io/rpm/6.1/archive.key
ADD confluent.repo /etc/yum.repos.d/

RUN yum update -y && \
    yum install -y sudo make git openssl openssl-devel libxml2-devel libxslt-devel \
        xmlsec1-devel xmlsec1-openssl-devel postgresql-devel autoconf libtool \
        ldns-devel libexpat-devel libcap-devel expat-devel readline-devel ldns epel-release \
        vim-common rpm-build flex bison wget unzip && \
    yum install -y cppcheck python2-pip java-1.8.0-openjdk centos-release-scl-rh && \
    yum install -y install scl-utils devtoolset-9 devtoolset-9-lib*-devel libzstd-static && \
    yum install -y librdkafka-devel 

RUN \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI2_VERSION}.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -f awscliv2.zip
  
 
ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins

ARG VERSION=3.20

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar && \
    chmod 755 /usr/share/jenkins && \
    chmod 644 /usr/share/jenkins/slave.jar
RUN mkdir /home/jenkins/workspace && \
    chown jenkins:jenkins /home/jenkins/workspace
RUN mkdir /home/jenkins/.jenkins && \
    chown jenkins:jenkins /home/jenkins/.jenkins

USER jenkins
VOLUME /home/jenkins/.jenkins
VOLUME /home/jenkins/workspace
WORKDIR /home/jenkins

ADD files/jenkins-slave.sh /home/jenkins

ENTRYPOINT ["/home/jenkins/jenkins-slave.sh"]
