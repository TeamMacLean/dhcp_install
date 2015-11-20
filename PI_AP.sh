#!/bin/sh

echo "This script is expecting to be ran on a fresh install of raspbian, otherwise it might break something"
echo "continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo "updating"
sudo apt-get update
sudo apt-get upgrade -y

echo "installing hostap and custom bin"
sudo apt-get install hostapd
wget http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip
unzip hostapd.zip
sudo mv /usr/sbin/hostapd /usr/sbin/hostapd.bak
sudo mv hostapd /usr/sbin/hostapd.edimax
sudo ln -sf /usr/sbin/hostapd.edimax /usr/sbin/hostapd
sudo chown root.root /usr/sbin/hostapd
sudo chmod 755 /usr/sbin/hostapd

echo "setting up hostap"
sudo echo "interface=wlan0" >> /etc/hostapd/hostapd.conf
sudo echo "driver=rtl871xdrv" >> /etc/hostapd/hostapd.conf
sudo echo "ssid=THEPI" >> /etc/hostapd/hostapd.conf
sudo echo "channel=6" >> /etc/hostapd/hostapd.conf
sudo echo "wmm_enabled=1" >> /etc/hostapd/hostapd.conf
sudo echo "wpa=1" >> /etc/hostapd/hostapd.conf
sudo echo "wpa_passphrase=THEPASSWORD" >> /etc/hostapd/hostapd.conf
sudo echo "wpa_key_mgmt=WPA-PSK" >> /etc/hostapd/hostapd.conf
sudo echo "wpa_pairwise=TKIP" >> /etc/hostapd/hostapd.conf
sudo echo "rsn_pairwise=CCMP" >> /etc/hostapd/hostapd.conf
sudo echo "auth_algs=1" >> /etc/hostapd/hostapd.conf
sudo echo "macaddr_acl=0" >> /etc/hostapd/hostapd.conf

sudo echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf' >> /etc/default/hostapd

echo "setting up network interfaces"
sudo echo "iface wlan0 inet static" >> /etc/network/interfaces
sudo echo "address 10.10.0.1" >> /etc/network/interfaces
sudo echo "netmask 255.255.255.0" >> /etc/network/interfaces

sudo echo "allow-hotplug wlan1" >> /etc/network/interfaces
sudo echo "iface wlan1 inet manual" >> /etc/network/interfaces
sudo echo "wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" >> /etc/network/interfaces

sudo echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > /etc/wpa_supplicant/wpa_supplicant.conf
sudo echo "update_config=1" >> /etc/wpa_supplicant/wpa_supplicant.conf
sudo echo "network={" >> /etc/wpa_supplicant/wpa_supplicant.conf
sudo echo 'ssid="staff"' >> /etc/wpa_supplicant/wpa_supplicant.conf
sudo echo "key_mgmt=NONE" >> /etc/wpa_supplicant/wpa_supplicant.conf
sudo echo "}" >> /etc/wpa_supplicant/wpa_supplicant.conf

echo "installing DHCP server"
sudo apt-get install isc-dhcp-server

echo "setting up DHCP server"
sudo echo "authoritative;" >> /etc/dhcp/dhcpd.conf
sudo echo "ddns-update-style none;" >> /etc/dhcp/dhcpd.conf
sudo echo "default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
sudo echo "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
sudo echo "log-facility local7;" >> /etc/dhcp/dhcpd.conf

sudo echo "subnet 10.10.0.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
sudo echo "range 10.10.0.25 10.10.0.50;" >> /etc/dhcp/dhcpd.conf
sudo echo "option domain-name-servers 8.8.8.8, 8.8.4.4;" >> /etc/dhcp/dhcpd.conf
sudo echo "option routers 10.10.0.1;" >> /etc/dhcp/dhcpd.conf
sudo echo "interface wlan0;" >> /etc/dhcp/dhcpd.conf
sudo echo "}" >> /etc/dhcp/dhcpd.conf


echo "setting up bridge network"
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
iptables-save > /etc/iptables.up.rules

sudo echo "#!/bin/sh" > /etc/network/if-pre-up.d/iptables
sudo echo "iptables-restore < /etc/iptables.up.rules exit 0" > /etc/network/if-pre-up.d/iptables #might need to remove 'exit 0'

sudo chown root:root /etc/network/if-pre-up.d/iptables
sudo chmod +x /etc/network/if-pre-up.d/iptables
sudo chmod 755 /etc/network/if-pre-up.d/iptables


#
# in /etc/rc.local add this before exit 0:
# sudo service isc-dhcp-server restart
#
echo "rebooting"
sudo reboot #just to be sure
