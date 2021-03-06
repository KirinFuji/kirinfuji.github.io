---
title: firewall-cmd cheatsheet
date: 2019-11-27 16:00:00 -08:00
published: false
categories:
- Security
tags:
- firewalld
description: A cheatsheet document for managing CentOS 7 firewalld/firewall-cmd
author: Kirin
blog_category: Security
layout: post
---

### Managing firewalld  
-- Display whether service is running  
`firewall-cmd --state`  
-- Another command to display status of service  
`systemctl status firewalld`  
-- To restart service  
`systemctl restart firewall-cmd`  
-- To reload the permanent rules  
`firewall-cmd --reload`  

### To start/stop/status firewalld service  
`systemctl start firewalld.service`  
`systemctl stop firewalld.service`  
`systemctl status firewalld.service`  

### To enable firewalld service from starting at boot time  
`systemctl enable firewalld`  

### To disable firewalld service from starting at boot time  
`systemctl disable firewalld`  

### To list details of default and active zones  
`firewall-cmd --get-default-zone`  
`firewall-cmd --get-active-zones`  
`firewall-cmd --list-all`  

### To add interface “eth1” to “public” zone  
`firewall-cmd --zone=public --change-interface=eth1`  

### To list available services  
`firewall-cmd --get-services`  

### To add “samba and samba-client” service to a specific zone. You may include, “permanent” flag to make this permanent change.  
`firewall-cmd --zone=public --add-service=samba --add-service=samba-client --permanent`  

### To list services configured in a specific zone.  
`firewall-cmd --zone=public --list-service`  

### To list and Add ports to firewall  
`firewall-cmd --list-ports`  
`firewall-cmd --zone=public --add-port=5000/tcp`  

### You may restart the Network service followed by Firewall server.  
`systemctl restart network.service`  
`systemctl restart firewalld.service`  
