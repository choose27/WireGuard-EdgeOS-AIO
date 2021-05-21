# Wireguard-EdgeOS-AIO
Collection of scripts to install Wireguard on Ubiquiti Edgerouter and easily add peers.

How to use:

*Work in progress*

1. Log into edgerouter cli.
2. mkdir wireguardaio && cd wireguardaio 
3. Curl the wg.sh script from github -- needs updated with full command.
4. chmod a+x wg.sh
5. configure
6. ./wg.sh
7. add your first peer with ./wgadd.sh wg0 nameofpeer
8. download wireguard app on ios/android
9. scan qr code to add peer


Script to install wireguard is from:
https://github.com/WireGuard/wireguard-vyatta-ubnt

Script to add peers is from this reddit post:
https://www.reddit.com/r/WireGuard/comments/fxcqaa/script_automate_adding_wireguard_peers_on/
I only made a few adjustments to automate adding peers.
