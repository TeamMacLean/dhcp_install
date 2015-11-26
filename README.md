# Install Access Point - Create a WiFi access point on a Raspberry Pi with a second WiFi dongle.

## Use
`make_access_point.sh` sets up the Pi with a second WiFi network acting as an access point.

## Pre-requisites
* A Raspberry Pi with an internet connection (we presume this is via a WiFi dongle in the USB port, but could be Ethernet).
* The script will reboot the system on completion - so make sure nothing is running.


## Install

0. Plug in your second WiFi dongle.
1. Download and unzip (or `git clone`) this package.
2. `cd` into the `dhcp_install` directory and type `./make_access_point.sh`

## Finding your Pi's network after reboot

The script will automatically reboot your system. When it comes back up, you should be able to browse for open WiFi with another machine. The Pi will broadcast its network as `THEPI` and the default password is `THEPASSWORD`.
You can change these values by editing the file `/etc/hostapd/hostapd.conf` e.g `sudo nano /etc/hostapd/hostapd.conf` and look for the following lines:

> ssid=THEPI

and

> wpa_passphrase=THEPASSWORD

set them to something more secure. You will need to reboot - `sudo reboot`


## Acknowledgements

This script relies on Dave Conroy's `hostapd` -
[Blog Post](http://www.daveconroy.com/using-your-raspberry-pi-as-a-wireless-router-and-web-server/)
Original Code -  [http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip](http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip)
