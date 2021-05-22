#!/bin/sh
# make sure script is run as group vyattacfg
if [[ $(id -g -n) != 'vyattacfg' ]]; then
	exec sg vyattacfg -c "$0 $@"
fi
## Remove WireGuard
curl https://raw.githubusercontent.com/mafredri/vyatta-wireguard-installer/master/wireguard.sh >> /config/WireGuardAIO/install.sh
chmod a+x /config/WireGuardAIO/install.sh
/bin/bash /config/WireGuardAIO/install.sh remove

## Remove WAN_LOCAL rule
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete firewall name WAN_LOCAL rule 540
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper delete system package repository
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end

## Remove qrcode
sudo apt remove qrencode -y
sudo apt autoremove -y

## Clean up space
sudo apt autoclean

## Remove key
rm /config/auth/wg.key

## Remove WireGuardAIO folder
rm -R /config/WireGuardAIO


