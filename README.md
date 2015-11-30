# Install Access Point - Create a WiFi access point on a Raspberry Pi with a second WiFi dongle.

## Use
`make_access_point.sh` sets up the Pi with a second WiFi network acting as an access point.

## Pre-requisites
* A Raspberry Pi with an internet connection (we presume this is via a WiFi dongle in the USB port, but could be Ethernet).
* The script will need to reboot the system on completion - so make sure nothing is running.


## Install

0. Plug in your second WiFi dongle.
1. Download and unzip (or `git clone`) this package.
2. `cd` into the `make_ap` directory and type `./make_access_point.sh`
3. During the process you'll be asked to specify network details, including the name for the WiFi connection (the SSID) you want to create and the password. You will be asked which IP address you would like: `10.10.0.1.X` is usually a useful one. Note all these.
4. You will be asked which interface you want to broadcast over. If you have two WiFi dongles, usually this will be `WLAN1` (wireless 1), because `WLAN0` is for the existing internet connected first dongle. If you are connecting to the internet with ethernet (`eth0`) then you can use `WLAN0` to broadcast.

## Finding your Pi's network after reboot

The script will quit and ask that you reboot - `sudo reboot`. When it comes back up you can access the Pi by switching your external computer's WiFi to connect to the SSID you specified, and you can get terminal access over ssh using `ssh pi@10.10.0.1`. 


## Acknowledgements

This script came from Jacek Tokar's
[Blog Post](http://raspberry-at-home.com/hotspot-wifi-access-point/)
