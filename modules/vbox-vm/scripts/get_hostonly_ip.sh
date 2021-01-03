#!/bin/sh
#
# This script returns the hostonly IP of a VirtualBox VM, using the MAC address of the associated nic.

HOSTONLYNET=""
MAC_ADDRESS=""
VM_IP=""

function check_deps {
  [[ -f $(which jq) ]] || { echo "jq command not detected in path, please install it";  exit 404; }
}

function parse_inputs {
  eval "$(jq -r '@sh "HOSTONLYNET=\(.hostonly_network) MAC_ADDRESS=\(.mac_address)"')"
  if [[ -z "${HOSTONLYNET}" ]] || [[ -z "${MAC_ADDRESS}" ]]; then
    echo "Failed to parse input arguments"
    exit 400 # http 400 - bad request
  fi
}

# Get hostonly IP of the newly created VirtualBox VM
function get_vm_ip {
	for i in $(seq 1 5); do
		sleep 5
		VM_IP=$(VBoxManage dhcpserver findlease --interface=${HOSTONLYNET} --mac-address=${MAC_ADDRESS} 2>/dev/null | awk -F': +' '/IP Address/ {print $2}')
		STATUS=$?
		if [[ ${STATUS} = 0 ]] && [[ -n "${VM_IP}" ]]; then
			break
		fi
	done

  jq -n \
    --arg vm_ip ${VM_IP} \
    '{"vm_ip": ($vm_ip)}'
}

check_deps &&
parse_inputs &&
get_vm_ip
