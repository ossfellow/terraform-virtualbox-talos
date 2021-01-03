#!/bin/sh
#
# This script creates a dedicated VirtualBox hostonly network and its DHCP server.

HOSTONLYNET=""

# Setup the hostonly network and its DHCP server, if required
if ! (VBoxManage list hostonlyifs | grep '${tf_ipv4_addr}' >/dev/null); then
	HOSTONLYNET=$(VBoxManage hostonlyif create | awk -F\' $2 '/vboxnet/ {print $2}')
	if [[ -z "$${HOSTONLYNET}" ]]; then
		echo "Could not create the VirtualBox hostonly network!"
		exit 417 # http 417 - expectation failed
	fi
	VBoxManage hostonlyif ipconfig $${HOSTONLYNET} --ip ${tf_ipv4_addr} --netmask=${tf_ipv4_netmask}
	VBoxManage hostonlyif ipconfig $${HOSTONLYNET} --ipv6 ${tf_ipv6_addr}
	VBoxManage dhcpserver add --interface=$${HOSTONLYNET} --server-ip=${tf_dhcp_ipv4_addr} --netmask=${tf_dhcp_ipv4_netmask} \
		--lower-ip=${tf_dhcp_lower_ipv4_addr} --upper-ip=${tf_dhcp_upper_ipv4_addr} --enable \
		--global --min-lease-time=${tf_min_lease_time} --default-lease-time=${tf_default_lease_time} --max-lease-time=${tf_max_lease_time} \
		--set-opt=15 ${tf_dns_domain} --set-opt-hex=0x77 ${tf_dns_domain}
fi
