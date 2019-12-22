---
title: firewall-cmd cheatsheet
date: 2019-12-01 00:00:00 Z
categories:
- security
tags:
- firewall-cmd
- firewalld
author: Ted
category: Security
layout: post
---

# Managing firewalld
`firewall-cmd --state`                 -- Display whether service is running
`systemctl status firewalld`           -- Another command to display status of service
`systemctl restart firewall-cmd`       -- To restart service
`firewall-cmd --reload`                -- To reload the permanent rules without interrupting existing persistent connections

# To start/stop/status firewalld service
`systemctl start firewalld.service`
`systemctl stop firewalld.service`
`systemctl status firewalld.service`

# To enable firewalld service from starting at boot time.
`systemctl enable firewalld`

# To disable firewalld service from starting at boot time.
`systemctl disable firewalld`

# To list details of default and active zones
`firewall-cmd --get-default-zone`
`firewall-cmd --get-active-zones`
`firewall-cmd --list-all`

# To add interface “eth1” to “public” zone.
`firewall-cmd --zone=public --change-interface=eth1`

# To list available services :
`firewall-cmd --get-services`

# To add “samba and samba-client” service to a specific zone. You may include, “permanent” flag to make this permanent change.
`firewall-cmd --zone=public --add-service=samba --add-service=samba-client --permanent`

# To list services configured in a specific zone.
`firewall-cmd --zone=public --list-service`

# To list and Add ports to firewall
`firewall-cmd --list-ports`
`firewall-cmd --zone=public --add-port=5000/tcp`

# You may restart the Network service followed by Firewall server.
`systemctl restart network.service`
`systemctl restart firewalld.service`