#!/bin/bash
# path for config file generation
path=/config/WireguardAIO
# router public key
routerpubkey=<pubkey>
endpoint=<ep>
allowedips=0.0.0.0/0

myname=$(basename "${0}")

if test $# != 2
then
    echo Usage: "${myname}" wg0 peer_name 1>&2
    exit 1
fi

peer_name="${2}"
interface="${1}"
routerip=$(/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show interfaces wireguard "${interface}" address | awk '{print $2}' | sed 's@/.*@@' | cut -d"." -f1-3)
dns=<dns>
port=$(/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show interfaces wireguard "${interface}" listen-port | awk '{print $2}')

pre_checks()
{
    # Sets path to the conf & peer files the script creates
    file="${path}"/"${peer_name}".conf
    peer="${path}"/"${peer_name}".peer

    # Makes sure the .conf and .peer file prefixes don't already exist. 
    if test -f "${file}"
    then
        echo "${myname}": "${file}" already exists 2>&2
        exit 2
    fi

    # Ensures the QR code fits on the screen, prompts if 
    # CLI window needs to be resized 
    set -- $(stty size)
}

generate_config()
{
    # Generates new private and public keys for the new device
    priv=$(wg genkey)
    psk=$(wg genkey)
    pub=$(echo "${priv}" | wg pubkey)
    ipnum=$(cat "${path}"/nextip.txt)

    # Creates the new conf file  
    cat > "${file}" <<END
[Interface]
PrivateKey = ${priv}
Address = ${routerip}.${ipnum}/32
DNS = ${dns}


[Peer]
PublicKey = ${routerpubkey}
Endpoint = ${endpoint}:${port}
AllowedIPs = ${allowedips}
PersistentKeepalive = 25
PresharedKey = ${psk}
END
}

increment_ip()
{
    echo $(expr $ipnum + 1) > "${path}"/nextip.txt
    (
        echo '[Peer]'
        echo PublicKey = "${pub}"
        echo AllowedIPs = "${routerip}"."${ipnum}"/32
    ) > "${peer}"
}

apply_config()
{
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard "${interface}" peer "${pub}" allowed-ips "${routerip}"."${ipnum}"/32
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard "${interface}" peer "${pub}" persistent-keepalive 25
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard "${interface}" peer "${pub}" preshared-key "${psk}"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set interfaces wireguard "${interface}" peer "${pub}" description "${peer_name}"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
}


display_temp_config()
{
    # Shows the .conf file to the user, to confirm it looks OK
    echo ""
    echo -n "-------------------------------"
    echo ""
    cat "${file}"
    echo ""
    echo -n "-------------------------------"
    echo ""
    echo -n "Review your new peer config above."
    echo
    echo ""
    echo -n "Commit? This will add this peer to your WireGuard config.  [Y/n]: "
}

display_new_config()
{
    echo ""
    echo -n "-------------------------------"
    echo ""
    cat "${file}"
    echo ""
    echo -n "-------------------------------"
    echo ""
    echo -n "Your new configuration."
    echo ""
}

display_qr()
{
    if [ -x "$(command -v qrencode)" ]
    then
        echo "Your new QR code."
        qrencode -t ansiutf8 < "${file}"
    fi
}

main()
{
    pre_checks

    generate_config

    display_temp_config

    read x
    if test x$x = x -o x$x = xy -o x$x = xY
    then
        # If accepted, create the peer file for the server
        rm -f "${peer}"
        
        # Sets the IP number to be used the next time the script runs
        increment_ip

        # Sets the new config 
        apply_config

        # Displays the new peer file, copy/paste for import if desired 
        display_new_config

        # Displays the the  QR code for scanning from mobile apps
        display_qr
    else
    rm -f "${file}"
    fi
}

main
