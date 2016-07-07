# XOS Configuration for ADTRAN CORD POD

## Introduction

This directory holds files that are used to configure XOS portion of the ADTRAN CORD/SDAN
POD.  For more information on the CORD project, check out
[the CORD website](http://cord.onosproject.org/).

XOS is composed of several core services:

  * A database backend (postgres)
  * A webserver front end (django)
  * A synchronizer daemon that interacts with the openstack backend
  * A synchronizer for each configured XOS service

Each service runs in a separate Docker container.  The containers are built
automatically by [Docker Hub](https://hub.docker.com/u/xosproject/) using
the HEAD of the XOS repository.

See the cord-pod/README.md file for any late changes, this file should be close to
what you need but may not be in-sync 100% of the time.  In general, we are trying
to run the basic XOS services + vAOS service.  The VTN/vRouter/Fabric/... XOS services
may get download/built/installed, but I am trying to avoid using these at this time.

For the Adtran POD(s), we are using the latest version of Docker Compose in order
to support the version 2 docker-compose format

## How to bring up the ADTRAN CORD

Installing a CORD POD involves these steps:
 1. Install OpenStack and ONOS as needed on your servers.  DevStack is acceptable
 2. Bring up XOS with the CORD services.  This step!

### Bringing up XOS

Most of the work occurs in two steps.  Editing the initial configuration and then installation.  The files you
need to edit are present in this directory and often in the service-profile/common subdirectory.  I suggest you
do these on a development machine where you can save things off to Perforce/GitHub and then copy them to the
target XOS VM/machine later for the actual building.

#### Files to edit

1. Edit the *admin-openrc.sh* in the _xos/configurations/adtn-cord_ directory to contain the proper OpenStack
 credentials.  This file is used during the creation of the *nodes.yaml* file (primarily to extract compute node names)
 that will be used and the *images.yaml* file for available glance images.
 It is for this reason you should have a working OpenStack installation with loaded images ready to go.  The images
 can also be loaded into XOS later with a CURL command.  How to do this is documented at the end of this file.

#### Building the world of XOS

1. On a Ubuntu 14.04 server (or a KVM VM) with network connectivity to both your OpenStack cluster(s) and ONOS
   cluster(s), copy the entire XOS tree to a directory (/opt/source/xos/ is a good choice).

    $ cd <to-this-directory>
    $ scp -r ../../../ <user>@<server>:/opt/source/xos/

2. Log into that remote Ubuntu 14.04 server into an install any build requirements.  All the
   steps here are available in a shell script 'InstallPrerequisites.sh'.
```
    $ sudo ./InstallPrerequisites.sh
```
or
```
    $ sudo apt-get update
    $ sudo apt-get install -y git curl make wget python-pip apt-transport-https ca-certificates \
                              linux-image-extra-$(uname -r) apparmor

    $ sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    $ echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' | sudo tee --append /etc/apt/sources.list.d/docker.list
    $ sudo apt-get update
    $ sudo apt-get purge lxc-docker
    $ apt-cache policy docker-engine
    $ sudo apt-get install -y docker-engine
    $ sudo service docker start
    $ sudo usermod -aG docker $(whoami)

    $ sudo pip install docker-compose
```
4. Build the XOS docker containers. XOS can then be brought up for ADTRAN CORD
   by running a few `make` commands. First, run:
```
    $ cd /opt/source/xos/configurations/adtn-cord/
    $ make
```
After this you will be able to login to the XOS GUI at
*http://xos/* using username/password `padmin@vicci.org/letmein`.
Before proceeding, you should verify that objects in XOS are
being sync'ed with OpenStack.  Log into the GUI and select *Users*
at left.  Make sure there is a green check next to `padmin@vicci.org`.

#### Building and vAOS observer

In the same _xos/configurations/adtn-cord_ subdirectory, enter:
```
    $ make cord-vaos
```
This will build and run vAOS observer docker container.


TODO: Add verification steps here


## Cleanup, Starting, an Stoping

The *Makefile* in the _xos/configurations/adtn-cord_ subdirectory contains targets to automatically
start, stop, and cleanup/remove the _Docker_ containers it created.

To cleanup, use the  *make rm* target.

## Adding new Glance image names into XOS
TODO:  Add the information on how to inject images into XOS here

## Adding new Nova 'Flavors' image names into XOS
TODO:  Add the information on how to inject flavors into XOS here