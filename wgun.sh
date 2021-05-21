#!/bin/sh
## Install WireGuard
curl https://raw.githubusercontent.com/mafredri/vyatta-wireguard-installer/master/wireguard.sh >> /config/WireGuardAIO/install.sh
chmod a+x /config/WireGuardAIO/install.sh
/bin/bash /config/WireGuardAIO/install.sh remove
## Set up the Interface
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete interfaces wireguard
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete firewall name WAN_LOCAL rule 40
#### get qrencode
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete system package repository
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end

sudo apt-get update
sudo apt-get install qrencode -y
sudo dpkg --remove wireguard
sudo dpkg --purge wireguard
rm -R /config/WireGuardAIO
rm /config/auth/wg.key

sudo apt remove qrencode -y
sudo apt autoremove -y
