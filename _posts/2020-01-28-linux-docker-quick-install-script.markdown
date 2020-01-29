---
title: Linux Docker Quick Install Script
date: 2020-01-28 23:47:00 -08:00
categories:
- Quick Install Guide
tags:
- Shell Script
description: How to get setup with docker and docker compose.
blog_category: Quick Install Guides
---

### Introduction

Docker is a linux container daemon and container language. Containers are basically a portable application. Systems are built to run docker, docker is built to run containers, so in theory you get really good portability of your application.

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