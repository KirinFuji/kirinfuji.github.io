---
title: Linux WAP Quick Install Guide
date: 2020-01-24 12:26:00 -08:00
categories:
- Quick Install Guide
tags:
- Shell Script
description: A short guide and script to get a wireless access point with or without
  IP forwarding enabled on a linux host.
blog_category: Quick Install Guides
---

## Requirements

- hostapd
- dnsmasq

```
sudo apt-get update
sudo apt-get install hostapd dnsmasq
```

## Setup

This is in alpha/beta stages. Script draft complete need to test.

{% highlight shell %}
#!/bin/bash

# Written by Kirin

# Edit the below variables to suit your needs.

# Variables

conf_dir="/root/wap" ;
wap_interface="wlan0" ;
wap_ssid="Default SSID" ;
wap_channel="7" ;
wap_psk="P@ssw0rd1" ;
wap_netaddr="192.168.1.0" ;
wap_subnet="255.255.255.0" ;
wap_ip="192.168.1.1" ;
wap_gw="192.168.1.1" ;
dnsd_listenaddr="127.0.0.1" ;
dnsd_fwd_target="1.1.1.1" ;
dhcpd_r_start="192.168.1.150" ;
dhcpd_r_end="192.168.1.200" ;
dhcpd_r_subnet="$wap_subnet" ;
dhcpd_option_3_gw="$wap_gw" ;
dhcpd_option_6_dns="$wap_ip" ;
fwd_packets="0" ; # Set to 1 to enable packet forwarding.
fwd_src_int="$wap_interface" ;
fwd_dst_int="eth0" ;
enable_autostart="0" ;

# Automated Script

# Put interface in monitor mode (Is this really a requirement?)
ifconfig "$wap_interface" down ;
iwconfig "$wap_interface" mode monitor ;
ifconfig "$wap_interface" up ;

# Setup Directory 
mkdir -p "$conf_dir" ;
pushd "$conf_dir" &> /dev/null ;

# Setup hostapd configuration
echo "interface=$wap_interface
driver=nl80211
ssid=$wap_ssid
hw_mode=g
channel=$wap_channel
macaddr_acl=0
ignore_broadcast_ssid=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
wpa_passphrase=$wap_psk" > hostapd.conf ;

# Setup dnsmasq configuration
echo "interface=$wap_interface
dhcp-range=$dhcpd_r_start,$dhcpd_r_end,$dhcpd_r_subnet,12h
dhcp-option=3,$dhcpd_option_3_gw
dhcp-option=6,$dhcpd_option_6_dns
server=$dnsd_fwd_target
log-queries
log-dhcp
listen-address=$dnsd_listenaddr" > dnsmasq.conf ;

# Setup routing table
ifconfig "$wap_interface" up "$wap_ip" netmask "$wap_subnet" ;
route add -net "$wap_netaddr" netmask "$wap_subnet" gw "$wap_ip" ;

# Run Daemons
hostapd -P $conf_dir/hostapd.pid -B $conf_dir/hostapd.conf ;
dnsmasq --pid-file=$conf_dir/dnsmasq.pid -C $conf_dir/dnsmasq.conf ;

popd &> /dev/null ;

# Setup Packet-Forwarding
if [ "$fwd_packets" = "1" ]; then

iptables --table nat --append POSTROUTING --out-interface "$fwd_dst_int" -j MASQUERADE ;
iptables --append FORWARD --in-interface "$fwd_src_int" -j ACCEPT ;

echo 1 > /proc/sys/net/ipv4/ip_forward ;

fi

if [ "$enable_autostart" = "1" ]; then
    if [ ! -f /etc/init.d/start-wap-services.sh ]; then
	
echo "!#/bin/sh
# Daemon Startup
hostapd -P $conf_dir/hostapd.pid -B $conf_dir/hostapd.conf ;
dnsmasq --pid-file=$conf_dir/dnsmasq.pid -C $conf_dir/dnsmasq.conf" > /etc/init.d/start-wap-services.sh ;

        if [ "$fwd_packets" = "1" ]; then

echo '# Packet Forwarding' >> /etc/init.d/start-wap-services.sh
echo "iptables --table nat --append POSTROUTING --out-interface $fwd_dst_int -j MASQUERADE ;
iptables --append FORWARD --in-interface $fwd_src_int -j ACCEPT ;
echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/init.d/start-wap-services.sh  ;

        fi

chmod +x /etc/init.d/start-wap-services.sh ;
update-rc.d start-wap-services.sh defaults ;

    else
        echo 'Autostart file (/etc/init.d/start-wap-services.sh) already exists.'
    fi
fi
{% endhighlight %}