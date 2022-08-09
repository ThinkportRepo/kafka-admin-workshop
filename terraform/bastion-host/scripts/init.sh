#!/bin/bash

cd /home/ubuntu
pwd
apt update
curl -O http://packages.confluent.io/archive/7.2/confluent-7.2.1.zip
apt install unzip -y
unzip confluent-7.2.1.zip
rm -rf confluent-7.2.1.zip
chown -R ubuntu:ubuntu confluent-7.2.1
echo "export PATH=$(pwd)/confluent-7.2.1/bin:$PATH" >> /home/ubuntu/.bashrc # everything will be executed as root per default
source /home/ubuntu/.bashrc

# install git
apt-get install git -y

# install docker
apt install docker.io -y
usermod -a -G docker ubuntu
chmod 666 /var/run/docker.sock

## install docker-compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
chgrp docker /usr/local/bin/docker-compose

# install openjdk 11
apt install openjdk-11-jdk -y

# clone local confluent platform repository
git clone https://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@github.com/ThinkportRepo/confluent-platform-all-in-one-security.git
chown -R ubuntu:ubuntu confluent-platform-all-in-one-security