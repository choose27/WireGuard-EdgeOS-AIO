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
10. commit;save;exit

I made a quick uninstaller so you can add/remove wg on demand. Or if you just want to remove it. Please review both scripts and understand them before you attempt to run them. ALWAYS make backups!

Uninstall:
1. configure
2. ./wgun.sh #this is downloaded during installation to the same directory the installer was in.
3. commit;save;exit

Script to install wireguard is from:
https://github.com/WireGuard/wireguard-vyatta-ubnt

Script to add peers is from this reddit post:
https://www.reddit.com/r/WireGuard/comments/fxcqaa/script_automate_adding_wireguard_peers_on/
I only made a few adjustments to automate adding peers.
