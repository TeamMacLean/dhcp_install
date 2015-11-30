# Install Access Point - Create a WiFi access point on a Raspberry Pi with a second WiFi dongle.

## Use
`make_access_point.sh` sets up the Pi with a second WiFi network acting as an access point.

## Pre-requisites
* A Raspberry Pi with an internet connection (we presume this is via a WiFi dongle in the USB port, but could be Ethernet).
* The script will reboot the system on completion - so make sure nothing is running.


## Install

0. Plug in your second WiFi dongle.
1. Download and unzip (or `git clone`) this package.
2. `cd` into the `make_ap` directory and type `./make_access_point.sh`
3. During the process you'll be asked to specify network details, including the name for the WiFi connection you want to create and the password. Note these down.

## Finding your Pi's network after reboot

The script will automatically reboot your system. When it comes back up, you should be able to browse for open WiFi with another machine. The Pi will broadcast its network as `THEPI` and the default password is `THEPASSWORD`.
You can change these values by editing the file `/etc/hostapd/hostapd.conf` e.g `sudo nano /etc/hostapd/hostapd.conf` and look for the following lines:

> ssid=THEPI

and

> wpa_passphrase=THEPASSWORD

set them to something more secure. You will need to reboot - `sudo reboot`


## Acknowledgements

This script came from Jacek Tokar's
[Blog Post](http://raspberry-at-home.com/hotspot-wifi-access-point/)
