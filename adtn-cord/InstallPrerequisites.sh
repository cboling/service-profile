#!/usr/bin/env bash

apt-get update
apt-get install -y git curl make wget python-pip apt-transport-https ca-certificates \
                   linux-image-extra-$(uname -r) apparmor

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

if [ ! -f /etc/apt/sources.list.d/docker.list ]
then
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list
elif [ ! `grep ubuntu-trusty /etc/apt/sources.list.d/docker.list >/dev/null 2>&1` ]
then
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list
fi

apt-get update
apt-get purge lxc-docker
apt-cache policy docker-engine

apt-get install -y docker-engine
sudo service docker start
usermod -aG docker $(whoami)

pip install docker-compose