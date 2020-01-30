---
title: Pi-Hole on CentOS 8
date: 2020-01-29 15:56:00 -08:00
permalink: "/posts/pihole-centos8-setup"
categories:
- Quick Install Guide
description: After fighting with the command line for a bit with the new subsystems
  I am unfamiliar with and learning CentOS 8 comes with Cockpit, a management GUI,
  I got it working quite easily.
blog_category: Quick Install Guides
---

### Description

{{% post.description %}}

### Introduction

I went to setup an Avorion game server on my CentOS 7 box only to find some issues with missing C++ libraries and CentOS 7 reporting everything is installed and up-to-date. Apparently its time to upgrade to CentOS 8. Tried to upgrade to CentOS 8 and found no supported methods or any that worked. Decided to reformat only to find they completely went the other direction and discourage using docker in lieu of podman+buildah (my containers were docker-compose containers).

### Walkthrough

After freshly installing CentOS 8 I was prompted with the command to start up Cockpit:
```
sudo systemctl start cockpit.socket
sudo systemctl enable cockpit.socket
```

Go to web-browser and enter:
```
https://<your_server_ip>:9090/
```

Log in and set the hostname of system and install updates.  

Click on Podman Containers on the left, its probably disabled so enabled it and check enable on boot.  

Click 'Get New Images' and type 'pihole'.  

Select 'docker.io/pihole/pihole:latest' and click download.

You should now have the pihole image and a play button, click the play button. Fill it out like so:
[pihole.PNG](/uploads/pihole.PNG)

Login to your server and spawn a shell or go to Terminal on the left navigation panel and enter the following (assuming you named your container pihole):
```
sudo podman logs pihole | grep password
```

You should get some lines that look like this:
```
Setting password: _gWhZDxA
+ pihole -a -p _gWhZDxA _gWhZDxA
```

Copy the password you found as you will need it for the pihole web interface.  

Note: You can also set a password via podman like this:
```
sudo podman exec test pihole -a -p <PASSWORD>
```

Now go to your pihole web interface:
```
http://<IP_OF_SERVER>/admin
```

At this point you should have a functioning pi-hole, be sure to configure it to your liking. I will describe how I am using it below:

Enter the password from before and go to settings.

Click on blocklists and paste the following:
```
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
https://mirror1.malwaredomains.com/files/justdomains
http://sysctl.org/cameleon/hosts
https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://hosts-file.net/ad_servers.txt
https://smokingwheels.github.io/Pi-hole/allhosts
https://raw.githubusercontent.com/hectorm/hmirror/master/data/adaway.org/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/adblock-nocoin-list/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/adguard-simplified/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/anudeepnd-adservers/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/disconnect.me-ad/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/disconnect.me-malvertising/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/disconnect.me-malware/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/disconnect.me-tracking/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/easylist/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/easyprivacy/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/eth-phishing-detect/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/fademind-add.2o7net/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/fademind-add.dead/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/fademind-add.risk/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/fademind-add.spam/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/kadhosts/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/malwaredomainlist.com/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/malwaredomains.com-immortaldomains/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/malwaredomains.com-justdomains/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/matomo.org-spammers/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/mitchellkrogza-badd-boyz-hosts/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/pgl.yoyo.org/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/ransomwaretracker.abuse.ch/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/someonewhocares.org/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/spam404.com/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/stevenblack/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/winhelp2002.mvps.org/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/zerodot1-coinblockerlists-browser/list.txt
https://raw.githubusercontent.com/hectorm/hmirror/master/data/zeustracker.abuse.ch/list.txt
https://raw.githubusercontent.com/CHEF-KOCH/Audio-fingerprint-pages/master/AudioFp.txt
https://raw.githubusercontent.com/CHEF-KOCH/Canvas-fingerprinting-pages/master/Canvas.txt
https://raw.githubusercontent.com/CHEF-KOCH/WebRTC-tracking/master/WebRTC.txt
https://raw.githubusercontent.com/CHEF-KOCH/CKs-FilterList/master/Anti-Corp/hosts/NSABlocklist.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
https://www.stopforumspam.com/downloads/toxic_domains_whole.txt
```

My DNS flow looks like this:  

Clients -> Pi-Hole -> Router -> Upstream DNS/TLS

DHCP: Assigns pihole server ip to DHCP clients.  
Pihole: Blocks domains on blacklist and forwards all other requests to firewall DNS resolver.  
Firewall: Registers hostnames and reverse lookups in its own resolver DB for all connected networks and forwards all other requests to an upstream DNS/TLS resolver.  

Goto pihole \> settings \> dns:  
Remove the default google servers and add a custom server with local resolver IP#PORT \<10.0.0.1#53>.  
Enable "Use Conditional Forwarding" configuring your local resolvers IP and search domain. 

The end result is that all queries on the network go to Pi-Hole first, sinkhole the bad domains, forward all others to firewall, firewall serves hostnames for all networked clients (dmz, vpn, lan, wlan) back to the Pi-Hole and forwards all other requests to an upstream DNS resolver using DNS/TLS/.