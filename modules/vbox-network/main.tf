locals {
  scripts_dir = "${path.module}/scripts"
}

# Generate the desired script, for creating a dedicated VBox hostonly network
resource "local_file" "vbox_network" {
  content = templatefile("${path.module}/add_network.tpl", {
    tf_ipv6_addr            = cidrhost(var.hostonly_ipv6_subnet, 1)
    tf_ipv4_addr            = cidrhost(var.hostonly_ipv4_subnet, 1)
    tf_ipv4_netmask         = cidrnetmask(var.hostonly_ipv4_subnet)
    tf_dhcp_ipv4_addr       = cidrhost(var.hostonly_ipv4_subnet, 2)
    tf_dhcp_ipv4_netmask    = cidrnetmask(var.hostonly_ipv4_subnet)
    tf_dhcp_lower_ipv4_addr = cidrhost(var.hostonly_ipv4_subnet, 5)
    tf_dhcp_upper_ipv4_addr = cidrhost(var.hostonly_ipv4_subnet, 65279)
    tf_min_lease_time       = var.dhcp_min_lease_time
    tf_max_lease_time       = var.dhcp_max_lease_time
    tf_default_lease_time   = var.dhcp_default_lease_time
    tf_dns_domain           = var.dns_domain
  })
  filename = "${local.scripts_dir}/add_network.sh"
}

# Create the VBox hostonly network and its DHCP server
resource "null_resource" "vbox_network" {
  provisioner "local-exec" {
    interpreter = [var.shell, "-c"]
    command     = "${local.scripts_dir}/add_network.sh"

  }
  depends_on = [local_file.vbox_network]
}

# Get the hostonly network, and first active network adapter of the host (macOS/Linux)
data "external" "network_info" {
  program = [var.shell, "${local.scripts_dir}/get_netinfo.sh"]

  query = {
    hostonlyip = cidrhost(var.hostonly_ipv4_subnet, 1)
  }

  depends_on = [null_resource.vbox_network]
}

# Prepare useful information about the VirtualBox network setup of this module
data "null_data_source" "hostonly_network" {
  inputs = {
    name           = data.external.network_info.result.hostonlynet
    subnet         = var.hostonly_ipv4_subnet
    first_dhcp_ip  = cidrhost(var.hostonly_ipv4_subnet, 5)
    last_dhcp_ip   = cidrhost(var.hostonly_ipv4_subnet, 65279)
    unused_segment = cidrsubnet(var.hostonly_ipv4_subnet, 8, 255)
  }
}

# Remove the VirtualBox hostonly network and its DHCP server, if requested
# Work around Terraform limitation of passing variables to destroy-time provisioners
resource "null_resource" "remove_vbox_network" {
  for_each = toset([join("|", [var.shell, tostring(var.remove_hostonlynet), cidrhost(var.hostonly_ipv4_subnet, 1)])])
  provisioner "local-exec" {
    when        = destroy
    interpreter = [tostring(split("|", each.key)[0])]
    command     = "${path.module}/scripts/remove_network.sh"

    environment = {
      REMOVE = split("|", each.key)[1]
      HNIFIP = split("|", each.key)[2]
    }
  }
}
