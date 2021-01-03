locals {
  br_mac_address = format("%s%s", upper(var.mac_address_prefix), random_string.mac_address[0].result) # Reserve for bridge interface
  ho_mac_address = format("%s%s", upper(var.mac_address_prefix), random_string.mac_address[1].result) # Reserve for hostonly interface
  nt_mac_address = format("%s%s", upper(var.mac_address_prefix), random_string.mac_address[2].result) # Reserve for nat interface

  scripts_dir = "${path.module}/scripts"
}

# Generate three random MAC addresses, for the VirtualBox VM
resource "random_string" "mac_address" {
  count = 3

  length           = 6
  lower            = false
  min_special      = 6
  override_special = "0123456789ABCDEF"

  keepers = {
    vm_name = var.vm_name
  }
}

# Generate the desired script, for building the VirtualBox VM
resource "local_file" "vbox_vm" {
  content = templatefile("${path.module}/build_vbox_vm.tpl", {
    tf_vbox_group       = var.vbox_group
    tf_vm_name          = var.vm_name
    tf_vm_description   = var.vm_description
    tf_cpus             = var.vm_specs.cpus
    tf_mem_size         = var.vm_specs.ram_size
    tf_disk_size        = var.vm_specs.disk_size
    tf_chipset          = var.chipset
    tf_bridge_adapter   = var.bridge_adapter
    tf_br_mac_address   = local.br_mac_address
    tf_hostonly_adapter = var.hostonly_network
    tf_ho_mac_address   = local.ho_mac_address
    tf_host_dns_access  = var.host_dns_access
    tf_nt_mac_address   = local.nt_mac_address
    tf_os_iso           = var.os_iso
    tf_frontend_style   = var.vm_frontend_style
    tf_autostart        = var.boottime_config.autostart
    tf_autostart_delay  = var.boottime_config.autostart_delay
  })
  filename = "${local.scripts_dir}/build_${var.vm_name}_vm.sh"

  depends_on = [random_string.mac_address]
}

# Wait before configuring and starting the next VM, to ensure VirtualBox can cope with multiple requests
resource "time_sleep" "vm_launch_delay" {
  create_duration = "3s"

  depends_on = [local_file.vbox_vm]
}

# Build the VirtualBox VM, using the specified specs
resource "null_resource" "vbox_vm" {
  provisioner "local-exec" {
    interpreter = [var.shell, "-c"]
    command     = "${local.scripts_dir}/build_${var.vm_name}_vm.sh"
  }

  depends_on = [time_sleep.vm_launch_delay]
}

# Wait until the VM network is configured, and VirtualBox has assigned it a hostonly IP address
resource "time_sleep" "ip_assignment_wait" {
  create_duration = var.ip_assignment_wait

  depends_on = [null_resource.vbox_vm]
}

# Get the hostonly IP address of the launched VirtualBox VM
data "external" "hostonly_network" {
  program = [var.shell, "${local.scripts_dir}/get_hostonly_ip.sh"]

  query = {
    hostonly_network = var.hostonly_network
    mac_address      = local.ho_mac_address
  }

  depends_on = [time_sleep.ip_assignment_wait]
}

resource "null_resource" "add_dns_record" {
  count = var.admin_password != "!" && var.node_fqdn != "" ? 1 : 0

  provisioner "local-exec" {
    when        = create
    interpreter = [var.shell]
    command     = "${local.scripts_dir}/update-local-dns.sh"

    environment = {
      PASSWORD   = var.admin_password
      DNS_FILE   = "/etc/hosts"
      DNS_ACTION = "add"
      IP         = data.external.hostonly_network.result.vm_ip
      NODE_FQDN  = var.node_fqdn
      NODE_ALIAS = var.node_alias
    }
  }

  depends_on = [data.external.hostonly_network]
}

# Tear down the VirtualBox VMs, when requested
resource "null_resource" "destroy_vm" {
  for_each = toset([format("%s|%s", var.shell, var.vm_name)])
  provisioner "local-exec" {
    when        = destroy
    interpreter = [tostring(split("|", each.key)[0]), "-c"]
    command     = <<-EOT
      VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
      VBoxManage unregistervm "$VM_NAME" --delete
    EOT

    environment = {
      VM_NAME = split("|", each.key)[1]
    }
  }
}

# Remove the local DNS record, for the destroyed VirtualBox VM
# Working around Terraform limitations about using variables in destroy time provisioners
resource "null_resource" "remove_dns_record" {
  for_each = toset([join("|", [var.shell, var.admin_password, var.node_fqdn])])
  provisioner "local-exec" {
    when        = destroy
    interpreter = [tostring(split("|", each.key)[0])]
    command     = "${path.module}/scripts/update-local-dns.sh"
    on_failure  = continue

    environment = {
      PASSWORD   = split("|", each.key)[1]
      DNS_FILE   = "/etc/hosts"
      DNS_ACTION = "remove"
      NODE_FQDN  = split("|", each.key)[2]
    }
  }

  depends_on = [null_resource.destroy_vm]
}
