#!/bin/bash

echo "This script expects to be run on a fresh install of Raspbian. It overwrites some configuration stuff.  There is a slight chance it might break something on a more customised setup..."
echo "Are you happy to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo "updating"
apt-get update
apt-get upgrade -y

echo "installing hostap and custom binary"
apt-get install hostapd -y
 mv /usr/sbin/hostapd /usr/sbin/hostapd.bak
 mv hostapd /usr/sbin/hostapd.edimax
 ln -sf /usr/sbin/hostapd.edimax /usr/sbin/hostapd
 chown root.root /usr/sbin/hostapd
 chmod 755 /usr/sbin/hostapd


echo "setting up hostap"
 echo "interface=wlan1" >> /etc/hostapd/hostapd.conf
 echo "driver=rtl871xdrv" >> /etc/hostapd/hostapd.conf
 echo "ssid=THEPI" >> /etc/hostapd/hostapd.conf
 echo "channel=6" >> /etc/hostapd/hostapd.conf
 echo "wmm_enabled=1" >> /etc/hostapd/hostapd.conf
 echo "wpa=1" >> /etc/hostapd/hostapd.conf
 echo "wpa_passphrase=THEPASSWORD" >> /etc/hostapd/hostapd.conf
 echo "wpa_key_mgmt=WPA-PSK" >> /etc/hostapd/hostapd.conf
 echo "wpa_pairwise=TKIP" >> /etc/hostapd/hostapd.conf
 echo "rsn_pairwise=CCMP" >> /etc/hostapd/hostapd.conf
 echo "auth_algs=1" >> /etc/hostapd/hostapd.conf
 echo "macaddr_acl=0" >> /etc/hostapd/hostapd.conf

 echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

echo "setting up network interfaces"
 echo "iface wlan1 inet static" >> /etc/network/interfaces
 echo "address 10.10.0.1" >> /etc/network/interfaces
 echo "netmask 255.255.255.0" >> /etc/network/interfaces

echo "installing DHCP server"
 apt-get install isc-dhcp-server

echo "setting up DHCP server"
 echo "authoritative;" >> /etc/dhcp/dhcpd.conf
 echo "ddns-update-style none;" >> /etc/dhcp/dhcpd.conf
 echo "default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
 echo "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
 echo "log-facility local7;" >> /etc/dhcp/dhcpd.conf

 echo "subnet 10.10.0.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
 echo "range 10.10.0.25 10.10.0.50;" >> /etc/dhcp/dhcpd.conf
 echo "option domain-name-servers 8.8.8.8, 8.8.4.4;" >> /etc/dhcp/dhcpd.conf
 echo "option routers 10.10.0.1;" >> /etc/dhcp/dhcpd.conf
 echo "interface wlan1;" >> /etc/dhcp/dhcpd.conf
 echo "}" >> /etc/dhcp/dhcpd.conf


echo "setting up bridge network"
 echo 1 > /proc/sys/net/ipv4/ip_forward
 echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
iptables-save > /etc/iptables.up.rules

 echo "#!/bin/sh" > /etc/network/if-pre-up.d/iptables
 echo "iptables-restore < /etc/iptables.up.rules exit 0" > /etc/network/if-pre-up.d/iptables #might need to remove 'exit 0'

 chown root:root /etc/network/if-pre-up.d/iptables
 chmod +x /etc/network/if-pre-up.d/iptables
 chmod 755 /etc/network/if-pre-up.d/iptables


#
# in /etc/rc.local add this before exit 0:
echo  "service isc-dhcp-server restart" >> /etc/rc.local
#
echo "rebooting"
# reboot #just to be sure
