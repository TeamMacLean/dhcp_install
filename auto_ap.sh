#!/bin/bash
#changes in version 1.1
#	- setup verifies WPA password length
#	- RTL8192CU added as the one needing special hostapd
#	- /etc/network/interfaces in now appended, not overvritten
#changes in version 1.2
#google public DNSes used
#apt-get update added

#variables init
run_time=`date +%Y%m%d%H%M`
#post_link="http://http://raspberry-at-home.com/hotspot-wifi-access-point/"
#log_file="ap_setup_log.${run_time}"

#cat /dev/null > ${log_file}

#  AP settings ##############################################  CHANGE THIS (if needed)#

AP_CHANNEL=1

# /AP settings ############################################## /CHANGE THIS #

#file info & disclaimer
#echo ""
#echo " ====================================================================== "          
#echo "title           :ap_setup_final.sh"                                                
#echo "description     :Automatic access point setup for raspberry pi."                   
#echo "author          :Jacek Tokar (jacek@raspberry-at-home.com)"		                 
#echo "author          :Tomasz Szczerba (tomek@raspberry-at-home.com)"	                 
#echo "author site     :raspberry-at-home.com"                                            
#echo "full guide      :${post_link}"                                                     
#echo "date            :20130601"                                                         
#echo "version         :1.0"                                                              
#echo "usage           :sudo ./ap_setup.sh"                                               
#echo "You can improve the script. Once you do it, share it with us. Keep credentials!"	 
#echo " ====================================================================== "          
#echo " DISCLAIMER:   "                                                                   
#echo "     Jacek, raspberry-at-home.com or anyone else on this blog is not responsible"  
#echo "     for bricked devices, dead SD cards, thermonuclear war, or any other things "  
#echo "     script may break. You are using this at your own responsibility...."          
#echo "     				....and usually it works just fine :)"          				 
#echo " ====================================================================== "          
#read -n 1 -p "Do you accept above terms? (y/n)" terms_answer
#echo ""

#if [ "${terms_answer,,}" = "y" ]; then
#        echo "Thank you!"                                                                
#else
#        echo "Head to ${post_link} read, comment and let us clear your doubts :)"        
#        exit 1
#fi

#echo "Updating repositories..."
apt-get update

AP_SSID='TheRPi'
CHIPSET="yes"
AP_WPA_PASSPHRASE = 'raspberry'
#if [ `lsusb | grep "RTL8188CUS\|RTL8192CU" | wc -l` -ne 0 ]; then
#        echo "Your WiFi is based on the chipset that requires special version of hostapd."              
#        echo "Setup will download it for you."                                                          
#CHIPSET="yes"
#else
#        echo "Some of the WiFi chipset require special version of hostapd."                             
#        echo "Please answer yes if you want to have different version of hostapd downloaded."           
#        echo "(it is not recommended unless you had experienced issues with running regular hostapd)" 
#        read ANSWER
#        if [ ${ANSWER,,} = "yes" ]; then
#                CHIPSET="yes"
#        else
#                CHIPSET="no"
#        fi
#fi

#echo "Checking network interfaces..."
NONIC=`netstat -i | grep ^wlan | cut -d ' ' -f 1 | wc -l`

#if [ ${NONIC} -lt 1 ]; then
#        echo "There are no wireless network interfaces... Exiting"
#        exit 1
#elif [ ${NONIC} -gt 1 ]; then
#TODO check this!!
#        echo "You have more than one wlan interface. Please select the interface to become AP: "
#        select INTERFACE in `netstat -i | grep ^wlan | cut -d ' ' -f 1`
#        do
#                NIC=${INTERFACE}
#		break
#        done
        #exit 1
#else
#        NIC=`netstat -i | grep ^wlan | cut -d ' ' -f 1`
#fi

NIC="wlan1"

#echo "Please select network interface you use to connect to the internet:"
#DNS="192.168.42.1"
#select INETNIC in `netstat -i | grep -v lo\|${NIC}\|Iface\|Kernel`
#do
#read -p "Please provide network interface that will be used as WAN connection (i.e. eth0): " WAN
WAN="wlan0"
DNS=`netstat -rn | grep ${WAN} | grep UG | tr -s " " "X" | cut -d "X" -f 2`
#echo "DNS will be set to " ${DNS}
#echo "You can change DNS addresses for the new network in /etc/dhcp/dhcpd.conf"
 #       break;
#done
#echo ""
#read -p "Please provide your new AP network (i.e. 192.168.10.X). Remember to put X at the end!!!  " NETWORK
NETWORK="10.10.10.X"

#if [ `echo ${NETWORK} | grep X$ | wc -l` -eq 0 ]; then
#	echo "Invalid AP network provided... No X was found at the end of you input. Setup will now exit."
#	exit 4
#fi
AP_ADDRESS=`echo ${NETWORK} | tr \"X\" \"1\"`
AP_UPPER_ADDR=`echo ${NETWORK} | tr \"X\" \"9\"`
AP_LOWER_ADDR=`echo ${NETWORK} | tr \"X\" \"2\"`
SUBNET=`echo ${NETWORK} | tr \"X\" \"0\"`


#echo ""
#echo ""
#echo "+========================================================================"
#echo "Your network settings will be:"
#echo "AP NIC address: ${AP_ADDRESS}  "
#echo "Subnet:  ${SUBNET} "
#echo "Addresses assigned by DHCP will be from  ${AP_LOWER_ADDR} to ${AP_UPPER_ADDR}"
#echo "Netmask: 255.255.255.0"
#echo "DNS: ${DNS}        "                                                                              
#echo "WAN: ${WAN}"

#read -n 1 -p "Continue? (y/n):" GO
#echo ""
#        if [ ${GO,,} = "y" ]; then
#                sleep 1
#        else
#				exit 2
#        fi
#
#
#echo "Setting up  $NIC"




#echo "Downloading and installing packages: hostapd isc-dhcp-server iptables."
#echo ""
apt-get -y install hostapd isc-dhcp-server iptables                                                     
service hostapd stop  > /dev/null
service isc-dhcp-server stop    > /dev/null
#echo ""

#echo "Backups:"

if [ -f /etc/dhcp/dhcpd.conf ]; then
        cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak.${run_time}
        echo " /etc/dhcp/dhcpd.conf to /etc/dhcp/dhcpd.conf.bak.${run_time}"                              
fi

if [ -f /etc/hostapd/hostapd.conf ]; then
        cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak.${run_time}
        echo "/etc/hostapd/hostapd.conf to /etc/hostapd/hostapd.conf.bak.${run_time}"                   
fi

if [ -f /etc/default/isc-dhcp-server ]; then
        cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak.${run_time}
        echo "/etc/default/isc-dhcp-server to /etc/default/isc-dhcp-server.bak.${run_time}"             
fi

if [ -f /etc/sysctl.conf ]; then
        cp /etc/sysctl.conf /etc/sysctl.conf.bak.${run_time}
        echo "/etc/sysctl.conf /etc/sysctl.conf.bak.${run_time}"                                        
fi

if [ -f /etc/network/interfaces ]; then
        cp /etc/network/interfaces /etc/network/interfaces.bak.${run_time}
        echo "/etc/network/interfaces to /etc/network/interfaces.bak.${run_time}"                       
fi


#echo "Setting up AP..."


echo "Configure: /etc/default/isc-dhcp-server"                                                          
echo "DHCPD_CONF=\"/etc/dhcp/dhcpd.conf\""                         >  /etc/default/isc-dhcp-server
echo "INTERFACES=\"$NIC\""                                         >> /etc/default/isc-dhcp-server

echo "Configure: /etc/default/hostapd"                                                          
echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\""                   > /etc/default/hostapd

echo "Configure: /etc/dhcp/dhcpd.conf"                                                          
echo "ddns-update-style none;"                                     >  /etc/dhcp/dhcpd.conf
echo "default-lease-time 86400;"                                     >> /etc/dhcp/dhcpd.conf
echo "max-lease-time 86400;"                                        >> /etc/dhcp/dhcpd.conf
echo "subnet ${SUBNET} netmask 255.255.255.0 {"                    >> /etc/dhcp/dhcpd.conf
echo "  range ${AP_LOWER_ADDR} ${AP_UPPER_ADDR}  ;"                >> /etc/dhcp/dhcpd.conf
echo "  option domain-name-servers 8.8.8.8, 8.8.4.4  ;"                       >> /etc/dhcp/dhcpd.conf
echo "  option domain-name \"home\";"                              >> /etc/dhcp/dhcpd.conf
echo "  option routers " ${AP_ADDRESS} " ;"                        >> /etc/dhcp/dhcpd.conf
echo "}"                                                           >> /etc/dhcp/dhcpd.conf

#echo "Configure: /etc/hostapd/hostapd.conf"
if [ ! -f /etc/hostapd/hostapd.conf ]; then
	touch /etc/hostapd/hostapd.conf
fi

echo "interface=$NIC"                                    >  /etc/hostapd/hostapd.conf
echo "ssid=${AP_SSID}"                                   >> /etc/hostapd/hostapd.conf
echo "channel=${AP_CHANNEL}"                             >> /etc/hostapd/hostapd.conf
echo "# WPA and WPA2 configuration"                      >> /etc/hostapd/hostapd.conf
echo "macaddr_acl=0"                                     >> /etc/hostapd/hostapd.conf
echo "auth_algs=1"                                       >> /etc/hostapd/hostapd.conf
echo "ignore_broadcast_ssid=0"                           >> /etc/hostapd/hostapd.conf
echo "wpa=2"                                             >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=${AP_WPA_PASSPHRASE}"               >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK"                              >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP"                                 >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP"                                 >> /etc/hostapd/hostapd.conf
echo "# Hardware configuration"                          >> /etc/hostapd/hostapd.conf
if [ ${CHIPSET} = "yes" ]; then

	echo "driver=rtl871xdrv"                         >> /etc/hostapd/hostapd.conf
	echo "ieee80211n=1"                              >> /etc/hostapd/hostapd.conf
    echo "device_name=RTL8192CU"                     >> /etc/hostapd/hostapd.conf
    echo "manufacturer=Realtek"                      >> /etc/hostapd/hostapd.conf
else
	echo "driver=nl80211"                            >> /etc/hostapd/hostapd.conf
fi

echo "hw_mode=g"                                         >> /etc/hostapd/hostapd.conf

#echo "Configure: /etc/sysctl.conf"
echo "net.ipv4.ip_forward=1"                             >> /etc/sysctl.conf

#echo "Configure: iptables"
iptables -t nat -A POSTROUTING -o ${WAN} -j MASQUERADE
iptables -A FORWARD -i ${WAN} -o ${NIC} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${NIC} -o ${WAN} -j ACCEPT
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "source-directory /etc/network/interfaces.d"  >  /etc/network/interfaces
echo "auto lo"  >>  /etc/network/interfaces
echo "iface lo inet loopback"  >>  /etc/network/interfaces
echo "iface eth0 inet manual"  >>  /etc/network/interfaces
echo "allow-hotplug ${WAN}"  >>  /etc/network/interfaces
echo "iface ${WAN} inet manual"  >>  /etc/network/interfaces
echo "    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"  >>  /etc/network/interfaces

#echo "Configure: /etc/network/interfaces"
echo "auto ${NIC}"                                         >>  /etc/network/interfaces
echo "allow-hotplug ${NIC}"                                >> /etc/network/interfaces
echo "iface ${NIC} inet static"                           >> /etc/network/interfaces
echo "        address ${AP_ADDRESS}"                       >> /etc/network/interfaces
echo "        netmask 255.255.255.0"                     >> /etc/network/interfaces
echo "up iptables-restore < /etc/iptables.ipv4.nat"      >> /etc/network/interfaces




#if [ ${CHIPSET,,} = "yes" ]; then
#	echo "Download and install: special hostapd version"
	wget "http://raspberry-at-home.com/files/hostapd.gz"                                           
     gzip -d hostapd.gz
     chmod 755 hostapd
     cp hostapd /usr/sbin/
#fi

ifdown ${NIC}                                                                                    
ifup ${NIC}                                                                                      
service hostapd start                                                                          
service isc-dhcp-server start                                                                  

#echo ""
#read -n 1 -p "Would you like to start AP on boot? (y/n): " startup_answer
#echo ""
#if [ ${startup_answer,,} = "y" ]; then
        echo "Configure: startup"                                                              
        update-rc.d hostapd enable                                                             
        update-rc.d isc-dhcp-server enable                                                     
#else
#        echo "In case you change your mind, please run below commands if you want AP to start on boot:"
#        echo "update-rc.d hostapd enable"
#        echo "update-rc.d isc-dhcp-server enable"
#fi



#echo ""
#echo "Do not worry if you see something like: [FAIL] Starting ISC DHCP server above... this is normal :)"
#echo ""
echo "REMEMBER TO RESTART YOUR RASPBERRY PI!!!"                                                
#echo ""
#echo "Enjoy and visit raspberry-at-home.com"

exit 0
