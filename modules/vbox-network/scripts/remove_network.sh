#!/bin/sh
#
# This script removes the identified VirtualBox hostonly network and its DHCP server, if requested.
# Care should be taken, as removing the network will impact existing VMs, with active hostonly IPs.

if [[ "${REMOVE}" == "true" ]] && (VBoxManage list hostonlyifs | grep "${HNIFIP}" >/dev/null); then
	HOSTONLYNET=$(VBoxManage list -s hostonlyifs | awk '! /VBoxNetworkName/ && /Name|IPAddress/ {print $2}' | awk '{printf (NR%2==0) ? "|" $0 "\n" : $0}' | awk -F\| '/'${HNIFIP}'/ {print $1;exit}')
  VBoxManage dhcpserver remove --network=HostInterfaceNetworking-${HOSTONLYNET} 2>/dev/null
  VBoxManage hostonlyif remove ${HOSTONLYNET} 2>/dev/null
fi
