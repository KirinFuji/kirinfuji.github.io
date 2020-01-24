---
title: Linux WAP Quick Install Guide
date: 2020-01-24 12:26:00 -08:00
---

## Requirements

- hostapd
- dnsmasq

```
sudo apt-get update
sudo apt-get install hostapd dnsmasq
```

## Setup


{% highlight shell %}
#!/bin/bash

# Written by Kirin

# REPLACE THE FOLLOWING IN "<>" INCLUDING THE LT AND GT SYMBOLS
wap_interface="<WLAN_INTERFACE>" ;
wap_ssid="<WIFI_SSID>" ;
wap_channel="<WIFI_CHANNEL>" ;
wap_psk="<WIFI_PASSWORD>" ;

# Example
# wap_interface="wlan0" ;
# wap_ssid="Default SSID" ;
# wap_channel="7" ;
# wap_psk="P@ssw0rd1" ;
# wap_netaddr="192.168.1.0"
# wap_subnet="255.255.255.0"
# wap_ip="192.168.1.1"
# wap_gw="192.168.1.1"
# wap_dns="$wap_dns_server"

# Automated Script

ifconfig "$wap_interface" down ;
iwconfig "$wap_interface" mode monitor ;
ifconfig "$wap_interface" up ;

mkdir -p /root/wap ;
pushd /root/wap 2> /dev/null ;

# hostapd configuration
echo '
interface="$wap_interface"
driver=nl80211
ssid="$wap_ssid"
hw_mode=g
channel="$wap_channel"
macaddr_acl=0
ignore_broadcast_ssid=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=TKIP
wpa_passphrase="$wap_psk"
' > hostapd.conf ;

# dnsmasq configuration
echo '
interface="$wap_interface"
dhcp-range="$wap_octet123.150,$wap_octet123.200,255.255.255.0,12h"
dhcp-option="3,$wap_ip"
dhcp-option="6,$wap_ip"
server="$wap_dns"
log-queries
log-dhcp
listen-address=127.0.0.1
' > dnsmasq.conf ;

ifconfig "$wap_interface" up "$wap_ip" netmask "$wap_subnet"
route add -net "$wap_netaddr" netmask "$wap_subnet" gw "$wap_ip"

dnsmasq -C dnsmasq.conf -d
hostapd hostapd.conf

{% endhighlight %}

