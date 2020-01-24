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

# Example
# wap_interface="wlan0" ;
# wap_ssid="Default SSID" ;
# wap_channel="7" ;
# wap_psk="P@ssw0rd1" ;
# wap_netaddr="192.168.1.0" ;
# wap_subnet="255.255.255.0" ;
# wap_ip="192.168.1.1" ;
# wap_gw="192.168.1.1" ;
# wap_dns_fwd_target="1.1.1.1" ;
# wap_dns_listenaddr="127.0.0.1" ;
# wap_dhcp_r_start="192.168.1.150"
# wap_dhcp_r_end="192.168.1.200"
# wap_dhcp_r_subnet="$wap_subnet"
# wap_dhcp_option_3_gw="$wap_gw"
# wap_dhcp_option_6_dns="$wap_ip"
# fwd_src_int
fwd_src_int

# Automated Script

ifconfig "$wap_interface" down ;
iwconfig "$wap_interface" mode monitor ;
ifconfig "$wap_interface" up ;

mkdir -p /root/wap ;
pushd /root/wap &> /dev/null ;

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
dhcp-range="$dhcp_r_start,$dhcp_r_end,$dhcp_r_subnet,12h"
dhcp-option="3,$wap_dhcp_option_3_gw"
dhcp-option="6,$wap_dhcp_option_6_dns"
server="$wap_dns_fwd_target"
log-queries
log-dhcp
listen-address="$dns_listenaddr"
' > dnsmasq.conf ;

ifconfig "$wap_interface" up "$wap_ip" netmask "$wap_subnet" ;
route add -net "$wap_netaddr" netmask "$wap_subnet" gw "$wap_ip" ;

hostapd hostapd.conf ;
dnsmasq -C dnsmasq.conf -d 

popd &> /dev/null

iptables --table nat --append POSTROUTING --out-interface "$fwd_dst_int" -j MASQUERADE
iptables --append FORWARD --in-interface "$fwd_src_int" -j ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward

exit 0
{% endhighlight %}

