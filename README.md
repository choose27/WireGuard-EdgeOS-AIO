# Wireguard-EdgeOS-AIO
Collection of scripts to install Wireguard on Ubiquiti Edgerouter and easily add peers.

How to use:

*Work in progress*

1. Log into edgerouter cli.
2. curl https://raw.githubusercontent.com/choose27/Wireguard-EdgeOS-AIO/main/wg.sh >> wg.sh && chmod a+x wg.sh && ./wg.sh
3. Add peers with: /config/WireGuard/wgadd.sh <wginterface> <peername> 

Add Peer Example: /config/WireGuard/wgadd.sh wg0 myphone

I made a quick uninstaller so you can add/remove wg on demand. Or if you just want to remove it. Please review both scripts and understand them before you attempt to run them. ALWAYS make backups!

Uninstall:
1. configure
2. /config/WireGuard/wgun.sh
3. commit;save;exit

Script to install wireguard is from:
https://github.com/WireGuard/wireguard-vyatta-ubnt

Script to add peers is from this reddit post:
https://www.reddit.com/r/WireGuard/comments/fxcqaa/script_automate_adding_wireguard_peers_on/
I only made a few adjustments to automate adding peers.
