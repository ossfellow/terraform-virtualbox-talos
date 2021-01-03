#!/bin/sh
#
# This script creates and configures a VirtualBox VM, based on provided specs;
# however, the script also makes configuration choices, which could only be modified by further
# customization of the Terraform module.

# The following attributes are hardcoded, based on the assumptions that most users don't need control over them
VRAM=16
CPU_EXECUTION_CAP=100 # Even though VirtualBox allows changes, it does not like values less than 100%
GRAPHIC_CONTROLLER="vmsvga"
DISK_SYSBUS="SATA" # Care should be taken if changed to IDE, as portcount doesn't apply there
DISK_CONTROLLER="IntelAhci"

VBOX_MACHINE_DIR="$(VBoxManage list systemproperties | awk -F: '/Default machine folder/ {gsub(/^[ \t]+/, "", $2); print $2}')"

# Create VBox VM group, and set it as current directory
function configure_group {
  cd "$${VBOX_MACHINE_DIR}"
  if [[ -n "${tf_vbox_group}" ]]; then
    mkdir -p ${tf_vbox_group}
    cd ${tf_vbox_group}
  fi
}

# Build the VM based on identified specs
function configure_vm {
	# Create VirtualBox VM
	VBoxManage createvm --name "${tf_vm_name}" --ostype "Linux_64" --register --basefolder ./

	# Customize VirtualBox VM's specs
	VBoxManage modifyvm "${tf_vm_name}" --description "${tf_vm_description}"
	VBoxManage modifyvm "${tf_vm_name}" --ioapic on --chipset ${tf_chipset} --rtcuseutc on
	VBoxManage modifyvm "${tf_vm_name}" --cpus ${tf_cpus} --cpuhotplug on --cpuexecutioncap $${CPU_EXECUTION_CAP}
	VBoxManage modifyvm "${tf_vm_name}" --memory ${tf_mem_size} --vram $${VRAM} --graphicscontroller $${GRAPHIC_CONTROLLER}
%{if tf_host_dns_access ~}
	VBoxManage modifyvm "${tf_vm_name}" --nic1 nat \
		--macaddress1 "${tf_nt_mac_address}" --cableconnected1 on --nicpromisc1 deny
  VBoxManage modifyvm "${tf_vm_name}" --natdnshostresolver1 on # Use host's DNS resolver, instead of VirtualBox's
	VBoxManage modifyvm "${tf_vm_name}" --nic2 bridged --bridgeadapter2 "${tf_bridge_adapter}" \
		--macaddress2 "${tf_br_mac_address}" --cableconnected2 on --nicpromisc2 deny
	VBoxManage modifyvm "${tf_vm_name}" --nic3 hostonly --hostonlyadapter3 "${tf_hostonly_adapter}" \
		--macaddress3 "${tf_ho_mac_address}" --cableconnected3 on --nicpromisc3 deny
%{else ~}
	VBoxManage modifyvm "${tf_vm_name}" --nic1 bridged --bridgeadapter1 "${tf_bridge_adapter}" \
		--macaddress1 "${tf_br_mac_address}" --cableconnected1 on --nicpromisc1 deny
	VBoxManage modifyvm "${tf_vm_name}" --nic2 hostonly --hostonlyadapter2 "${tf_hostonly_adapter}" \
		--macaddress2 "${tf_ho_mac_address}" --cableconnected2 on --nicpromisc2 deny
%{endif ~}
	VBoxManage modifyvm "${tf_vm_name}" --autostart-enabled ${tf_autostart} --autostart-delay ${tf_autostart_delay}

	# Create Disk and connect OS ISO
	VBoxManage createmedium --filename "./${tf_vm_name}/${tf_vm_name}.vdi" --size ${tf_disk_size} --format VDI
	VBoxManage storagectl "${tf_vm_name}" --name "$${DISK_SYSBUS}" --add sata --controller $${DISK_CONTROLLER} --portcount 2 --hostiocache on --bootable on
	VBoxManage storageattach "${tf_vm_name}" --storagectl "$${DISK_SYSBUS}" --port 0 --device 0 --type hdd --nonrotational on --hotpluggable off --medium  "./${tf_vm_name}/${tf_vm_name}.vdi"
	VBoxManage storageattach "${tf_vm_name}" --storagectl "$${DISK_SYSBUS}" --port 1 --device 0 --type dvddrive --hotpluggable on --medium "${tf_os_iso}"
	VBoxManage modifyvm "${tf_vm_name}" --boot1 disk --boot2 dvd --boot3 none --boot4 none
}

# Start the VM
function start_vm {
	VBoxManage startvm "${tf_vm_name}" --type ${tf_frontend_style} # either gui, headless, or separated
	VBoxManage showvminfo "${tf_vm_name}" >/dev/null
}

configure_group &&
configure_vm &&
start_vm
