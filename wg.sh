#!/bin/sh
## Install WireGuard
curl https://raw.githubusercontent.com/mafredri/vyatta-wireguard-installer/master/wireguard.sh >> install.sh
chmod a+x install.sh
/bin/bash install.sh install

## Set up the Interface
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin

#### get qrencode
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set system package repository stretch components 'main contrib non-free'
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set system package repository stretch distribution stretch
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set system package repository stretch url http://http.us.debian.org/debian
#commit; save; exit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end
## Generate Keys
wg genkey | tee /config/auth/wg.key | wg pubkey >  wg.public

/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard wg0 address 10.254.254.1/24
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard wg0 listen-port 51820
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard wg0 route-allowed-ips true
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard wg0 private-key /config/auth/wg.key
### check wan local rules and change the number accordingly ###
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 40 action accept
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 40 description 'WireGuard'
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 40 destination port 51820
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall name WAN_LOCAL rule 40 protocol udp

/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper end

sudo apt-get update
sudo apt-get install qrencode -y

## Prep the automatic peer configuration
curl https://files.tsok.ml/s/AFFKEKEmm9iBJgG/download >> wgadd.sh
routerpubkey=$(cat wg.public)
sed -i s[rOuTeRPUblicKey12345[$routerpubkey[ wgadd.sh
echo "Enter your endpoint domain or ip"
read endpoint
sed -i s[yourdomain.com[$endpoint[ wgadd.sh
chmod a+x wgadd.sh
echo 2 >> nextip.txt
echo "All done! Run './wgadd.sh wg0 peername' to generate a QR code for the app"
