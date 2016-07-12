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

Each service runs in a separate Docker container.  Unlike the ON.LAB/CORD containers,
all images and containers that the ADTRAN CORD POD will used are built locally.  Later on we
may decide to place them on the Adtran docker repository, but it really currently takes less
than an hour to build them all local.

See the 'origina' cord-pod/README.md file for any late changes, this file should be close to
what you need but may not be in-sync 100% of the time.  In general, we are trying
to run the basic XOS services + vAOS service.  The VTN/vRouter/Fabric/... XOS services
may get download/built/installed, but I am trying to avoid using these at this time.

For the Adtran POD(s), we are using the latest version of Docker Compose in order
to support the version 2 docker-compose format.  This format allows us to specify both
the docker image name and the local build directory (so we build all the images locally).

## How to bring up the ADTRAN CORD

Installing a CORD POD involves these steps:
 1. Install OpenStack and ONOS as needed on your servers.  DevStack is acceptable.
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

 Also pull down the root SSH keys (public and private) and place them in this directory with the name 'id_rsa'
 and 'id_rsa.pub'.

#### Building the world of XOS

1. On a Ubuntu 14.04 server or later (or a KVM VM) with network connectivity to both your OpenStack cluster(s) and ONOS
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
4. The XOS UI container (once built) will launch on the standard HTTP port (80) and the XOS database will also
   launch on the default postgresql port (5432).  You may want to stop both apache and postgresql if they are
   on your system with the following commands:
```
    $ service apache2 stop
    $ service postgreql stop
```
   Note that if you reboot, you will need stop these again before starting up your XOS containers

5. Build the XOS docker containers. XOS can then be brought up for ADTRAN CORD
   by running a few `make` commands. First, run:
```
    $ cd .../service-profiles/adtn-cord/              (this directory !!!!)
    $ make
```
   This may take 15 minutes to an hour.  It will build all the synchronizers and also do
   the initial OpenStack deployment and site creation for you (use to be a manual step
   that was done with the XOS UI).

   Log into the XOS UI.  The username/password is **_'TriplePoint@adtran.com/adtran'_**
   and the orginal XOS defualt password `padmin@vicci.org/letmein` is also still valid.

   You should see the deployment and site fully created.  Note that no Services have been
   installed into XOS yet even though their respective synchronizing docker containers may
   have already been started.

### Installing the XOS Services

The current makefile configuration builds the ADTRAN vAOS synchronizer as well as several of the
on.lab syncronizers (_fabric, vSG, onos, ..._) but we currently are only concerned with vAOS at
this point.

#### Modifying the initial XOS TOSCA files.

1. Edit the _mgmt-net.yaml_ file to contain the proper CIDR for your managment network.  This
   can be found on ~line 20 of _mgmt-net.yaml_.



#### Installing the vAOS Service into XOS

The vAOS service can be built with the command:
```
    $ cd .../service-profiles/adtn-cord/              (this directory !!!!)
    $ make cord
```
You may notice that this pulls down the **vsg** image that is used in the on.lab version of CORD
and installs it into glance.  This is as intended since some initial side-by-side comparisons
between it and vAOS may be made.  I you do not need this image, edit the **Makefile** so that
the _cord_ target is not dependent upon _vsg_custom_images_.


## Cleanup, Starting, an Stopping
**TODO**

## Adding new Glance image names into XOS
**TODO**

## Adding new Nova 'Flavors' image names into XOS
**TODO**