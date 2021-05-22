#!/bin/sh
## Create folder if needed
if [ ! -d /config/WireGuardAIO ]; then
  mkdir -p /config/WireGuardAIO;
fi

## Install WireGuard from mafredri's script
curl https://raw.githubusercontent.com/mafredri/vyatta-wireguard-installer/master/wireguard.sh >> /config/WireGuardAIO/install.sh
chmod a+x /config/WireGuardAIO/install.sh
/bin/bash /config/WireGuardAIO/install.sh install

## Add WAN_LOCAL rule
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 540 action accept
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 540 description 'WireGuard'
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 540 destination port 51820
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 540 protocol udp
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end

## Generate Keys
wg genkey | tee /config/auth/wg.key | wg pubkey >  /config/WireGuardAIO/wg.public

## Add repo and WAN_LOCAL Rules
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set system package repository stretch components 'main contrib non-free'
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set system package repository stretch distribution stretch
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set system package repository stretch url http://http.us.debian.org/debian
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end

## Install qrencode
sudo apt-get update
sudo apt-get install qrencode -y

## Add the interface
source /opt/vyatta/etc/functions/script-template
set interfaces wireguard wg0 address 10.254.254.1/24
set interfaces wireguard wg0 listen-port 51820
set interfaces wireguard wg0 route-allowed-ips true
set interfaces wireguard wg0 private-key /config/auth/wg.key
commit save

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
read -p 'Enter DNS server(s): ' -e -i '1.1.1.1,1.0.0.1' wgdns
sed -i s['<dns>'[$wgdns[ /config/WireGuardAIO/wgadd.sh
chmod a+x /config/WireGuardAIO/wgadd.sh
echo 2 >> /config/WireGuardAIO/nextip.txt
echo "All done! Run '/config/WireGuardAIO/wgadd.sh wg0 peername' to generate a QR code for the app"
exit
