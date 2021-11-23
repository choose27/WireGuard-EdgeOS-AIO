#!/bin/sh
# make sure script is run as group vyattacfg
if [[ $(id -g -n) != 'vyattacfg' ]]; then
	exec sg vyattacfg -c "$0 $@"
fi

## Create folder if needed
if [ ! -d /config/WireGuardAIO ]; then
  mkdir -p /config/WireGuardAIO;
fi

config=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper

## Get address and port
read -p 'Enter address for WireGuard: ' -e -i '10.254.254.1/24' wireguardip
read -p 'Enter port for Wireguard: ' -e -i '51820' wireguardport
read -p 'Enter WAN_LOCAL rule number: ' -e -i '540' wanlocalnum

## Install WireGuard from mafredri's script
curl https://raw.githubusercontent.com/mafredri/vyatta-wireguard-installer/master/wireguard.sh >> /config/WireGuardAIO/install.sh
chmod a+x /config/WireGuardAIO/install.sh
/bin/bash /config/WireGuardAIO/install.sh install


## Add WAN_LOCAL rule
$config begin
$config set firewall name WAN_LOCAL rule $wanlocalnum action accept
$config set firewall name WAN_LOCAL rule $wanlocalnum description 'WireGuard'
$config set firewall name WAN_LOCAL rule $wanlocalnum destination port $wireguardport
$config set firewall name WAN_LOCAL rule $wanlocalnum protocol udp
## Add repo and WAN_LOCAL Rules
$config set system package repository stretch components 'main contrib non-free'
$config set system package repository stretch distribution stretch
$config set system package repository stretch url http://http.us.debian.org/debian
$config commit
$config save
$config end

## Generate Keys
wg genkey | tee /config/auth/wg.key | wg pubkey >  /config/WireGuardAIO/wg.public

## Add the interface
$config begin
$config set interfaces wireguard wg0 address $wireguardip
$config set interfaces wireguard wg0 listen-port $wireguardport
$config set interfaces wireguard wg0 route-allowed-ips true
$config set interfaces wireguard wg0 private-key /config/auth/wg.key
$config commit
$config save
$config end

## Install qrencode
sudo apt-get update
sudo apt-get install qrencode -y

## Grab uninstaller
curl https://raw.githubusercontent.com/choose27/WireGuard-EdgeOS-AIO/main/wgun.sh >> /config/WireGuardAIO/wgun.sh
chmod a+x /config/WireGuardAIO/wgun.sh

## Prep the automatic peer configuration
curl https://raw.githubusercontent.com/choose27/WireGuard-EdgeOS-AIO/main/wgadd.sh >> /config/WireGuardAIO/wgadd.sh
routerpubkey=$(cat /config/WireGuardAIO/wg.public)

#using [ to split up my sed commands because I have not seen it in the public key output.
sed -i s['<pubkey>'[$routerpubkey[ /config/WireGuardAIO/wgadd.sh
read -p 'Enter your endpoint domain or ip: ' -e -i 'mydomainorpublicip.com' endpoint
sed -i s['<ep>'[$endpoint[ /config/WireGuardAIO/wgadd.sh
#read -p 'Enter DNS server(s): ' -e -i '1.1.1.1,1.0.0.1' wgdns
#sed -i s['<dns>'[$wgdns[ /config/WireGuardAIO/wgadd.sh
chmod a+x /config/WireGuardAIO/wgadd.sh
echo 2 >> /config/WireGuardAIO/nextip.txt
ln -s /config/WireGuardAIO/wgadd.sh wgadd
ln -s /config/WireGuardAIO/wgun.sh wg-uninstall
echo "All done! Run './wgadd wg0 peername' to generate a QR code for the app"
exit
