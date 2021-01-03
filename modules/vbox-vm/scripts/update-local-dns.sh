#!/bin/sh
#
# This script is used for adding and removing DNS records for VirtualBox vm instances, launched by Terraform

if [[ "${DNS_ACTION}" == "add" ]] && [[ $(grep -c "${IP}   ${NODE_ALIAS}   ${NODE_FQDN}" /etc/hosts) == 0 ]]; then
  if (uname -a | grep -i 'darwin' >/dev/null); then # Host is macOS
    echo "${PASSWORD}" | sudo -S -k sed -i "" '$a\
'"${IP}   ${NODE_ALIAS}   ${NODE_FQDN}"'
' ${DNS_FILE} # add the DNS A record
  else  # Host is Linux
    echo "${PASSWORD}" | sudo -S -k sed -i '$a'"${IP}   ${NODE_ALIAS}   ${NODE_FQDN}"'' ${DNS_FILE} # add the DNS A record
  fi
elif [[ "${DNS_ACTION}" == "remove" ]] && [[ "${PASSWORD}" != "!" ]]; then
  if (uname -a | grep -i 'darwin' >/dev/null); then # Host is macOS
    echo "${PASSWORD}" | sudo -S -k sed -i "" "/${NODE_FQDN}/d" ${DNS_FILE} # remove the DNS A record
  else  # Host is Linux
    echo "${PASSWORD}" | sudo -S -k sed -i "/${NODE_FQDN}/d" ${DNS_FILE} # remove the DNS A record
  fi
fi
