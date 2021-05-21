#!/bin/sh
## Install WireGuard
curl https://files.tsok.ml/s/XdBKnaJwREoCQz7/download >> install.sh
chmod a+x install.sh
/bin/bash install.sh remove
wait
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
rm nextip.txt
rm wg.public
rm wgadd.sh
rm install.sh
rm /config/auth/wg.key
sudo apt remove qrencode -y
sudo apt autoremove -y
