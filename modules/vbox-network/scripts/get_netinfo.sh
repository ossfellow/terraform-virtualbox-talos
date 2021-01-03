#!/bin/sh
#
# This returns the first active bridge adapter name of the host (macOS/Linux).

BRIDGEADAPTER=""
HOSTONLYNET=""
HOSTONLYIP=""

function check_deps {
  [[ -f $(which jq) ]] || { echo "jq command not detected in path, please install it";  exit 404; }
}

function parse_inputs {
  eval "$(jq -r '@sh "HOSTONLYIP=\(.hostonlyip)"')"
  if [[ -z "${HOSTONLYIP}" ]]; then
    echo "Failed to parse input arguments"
    exit 400 # http 400 - bad request
  fi
}

# Get the first active host network adapter, for bridge networking, and name of the configured hostonly network
function get_network_info {
	HOSTONLYNET=$(VBoxManage list -s hostonlyifs | awk '! /VBoxNetworkName/ && /Name|IPAddress/ {print $2}' | awk '{printf (NR%2==0) ? "|" $0 "\n" : $0}' | awk -F\| '/'${HOSTONLYIP}'/ {print $1;exit}')
	BRIDGEADAPTER=$(VBoxManage list -s bridgedifs | awk -F'  +' '! /VBoxNetworkName/ && /Name|IPAddress/ {print $2}' | awk '{printf (NR%2==0) ? "|" $0 "\n" : $0}' | awk -F\| '! /0.0.0.0/ {print $1; exit}')

  jq -n \
    --arg hostonlynet "${HOSTONLYNET}" \
		--arg bridgeadapter "${BRIDGEADAPTER}" \
    '{"hostonlynet": ($hostonlynet), "bridgeadapter": ($bridgeadapter)}'
}

check_deps &&
parse_inputs &&
get_network_info
