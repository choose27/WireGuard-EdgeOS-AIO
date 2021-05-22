# WireGuard-EdgeOS-AIO
Collection of scripts to install Wireguard on Ubiquiti Edgerouter and easily add peers.

How to use:

*Work in progress*

1. Log into edgerouter cli.
2. curl https://raw.githubusercontent.com/choose27/Wireguard-EdgeOS-AIO/main/wg.sh >> wg.sh && chmod a+x wg.sh && ./wg.sh
3. Add peers with: ./wgadd <wginterface> <peername> 

Add Peer Example: ./wgadd wg0 myphone

Script is removed automatically after installation.
  
Uninstall:
1. ./wg-uninstall

Script to install wireguard is from:
https://github.com/WireGuard/wireguard-vyatta-ubnt

Script to add peers is from this reddit post:
https://www.reddit.com/r/WireGuard/comments/fxcqaa/script_automate_adding_wireguard_peers_on/
