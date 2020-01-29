---
title: Linux Docker Quick Install Guide
date: 2020-01-28 23:47:00 -08:00
categories:
- Quick Install Guide
tags:
- Shell Script
description: How to get setup with docker and docker compose. CentOS 7 & CentOS 8
blog_category: Quick Install Guides
---

### Introduction

Docker is a linux container daemon and container language. Containers are basically a portable application. Systems are built to run docker, docker is built to run containers, so in theory you get really good portability of your application. (Until docker gets forked to hell and everyone wants to maintain their own container daemon as you will see below.)

### Installation

The below code will install the following:  
-yum-utils  
-device-mapper-persistent-data  
-lvm2  
-docker-ce  
-docker-ce-cli  
-containerd.io  
-docker-compose  


{% highlight shell %}
#!/bin/bash

# Written by Kirin

# Run the below to Install fresh docker on centos 7

sudo yum install -y yum-utils device-mapper-persistent-data lvm2 ;
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo ;
sudo yum install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker ;


# Run the below to Install fresh docker-compose on centos 7 (add-on)

# Note: You will want to go here: (https://github.com/docker/compose/releases/) to see if there is a more up-to-date version. Latest version as of 1-28-2020 is "1.25.3". The code will figure out your linux version, just replace "1.25.3" with the new version number.

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose ;
sudo chmod +x /usr/local/bin/docker-compose ;
sudo docker-compose --version ;
sudo echo "Finished." ;
{% endhighlight %}


### Centos 8

Unfortunately CentOS 8 ships with podman and seems to be discouraging use of docker. In my case I already had a few projects built with docker-compose and did not want to learn a new hosting method right now. Here is how I got docker + docker-compose working on CentOS 8.

The below code will install the following(and any dependencies):  
-device-mapper-persistent-data  
-lvm2  
-docker-ce  
-docker-ce-cli  
-containerd.io  
-docker-compose  

Will remove the following(and any dependencies):  
-podman  

Will disable the following services:  
-firewalld  

Please be advised this will leave you with a blank iptables firewall with everything open.

{% highlight shell %}
#!/bin/bash

# Written by Kirin

# Run the below to Install fresh docker on centos 8
sudo dnf remove -y podman ;
sudo dnf install -y device-mapper-persistent-data lvm2 ;
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo ;
sudo dnf -y --nobest install docker-ce docker-ce-cli containerd.io ;
sudo systemctl start docker ;
sudo systemctl enable docker ;


# Run the below to Install fresh docker-compose on centos 8 (add-on)

# Note: You will want to go here: (https://github.com/docker/compose/releases/) to see if there is a more up-to-date version. Latest version as of 1-28-2020 is "1.25.3". The code will figure out your linux version, just replace "1.25.3" with the new version number.

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose ;
sudo chmod +x /usr/local/bin/docker-compose ;
sudo docker-compose --version ;
sudo echo "Finished." ;

# Unfortunately something about docker on CentOS 8 with FirewallD is broken (despite it working somewhat on CentOS 7 with minor quirks) so we will have to turn off firewalld or your containers will simply be firewalled both directions.

sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Im not going to cover setting up a basic iptables firewall but its not hard the net is full of them but you should use a firewall if your server is exposed.

{% endhighlight %}

I use a docker-compose pi-hole project for my networks DNS Sinkhole and a few IRC bots and really like CentOS, just trying CentOS 8 out now and learning that podman ships with it I suppose ill create a podman pi-hole container when I can get around to it. (At a glance I think podman can run docker containers, however I have my doubts about docker-compose containers.)

After all the above I went to start my container and something was already listening on port 53. Apparently my CentOS 8 came with systemd-resolved running so I had to turn that off too.

```
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```