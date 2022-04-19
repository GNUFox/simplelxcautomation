#!/bin/bash

function help() {
  cat << EOF

SimpleLXCSetupAutomation:

Usage:

  init_container.sh -i <container IP address> -g <gateway IP address> -d <list of DNS IPs>

EOF
}

DEFAULT_IP_DNS="9.9.9.9" # Using Quad9 as default DNS

while getopts i:g:d: option 
do 
  case "${option}" in 
    i) IP_ADDR=${OPTARG};; 
    g) IP_GATEWAY=${OPTARG};; 
    d) IP_DNS=${OPTARG};;
  esac 
done 


if [ "$IP_ADDR" == "" ] || [ "$IP_GATEWAY" == "" ]; then
  echo
  echo "ERROR: Must provide Container and Gateway IP Adresses"
  echo
  help
  exit 0
fi

if [ "$IP_DNS" == "" ]; then
  IP_DNS=$DEFAULT_IP_DNS
  echo "No DNS IP provided, using $IP_DNS as default"
fi


INTERFACES_FILE="/etc/network/interfaces"


cat << EOF > $INTERFACES_FILE
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
	address $IP_ADDR
	gateway $IP_GATEWAY
	dns-nameservers $IP_DNS

source /etc/network/interfaces.d/*
EOF

echo "nameserver $IP_DNS" >> /etc/resolv.conf

# reboot to make changes effective (easiest way)
reboot
