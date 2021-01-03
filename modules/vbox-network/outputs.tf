output "bridge_adapter" {
  description = "Host's first active bridge adapter"
  value       = data.external.network_info.result.bridgeadapter
}

output "hostonly_network" {
  description = "Useful information about the VirtualBox hostonly network configuration"
  value = {
    "name"           = data.null_data_source.hostonly_network.outputs["name"],
    "subnet"         = data.null_data_source.hostonly_network.outputs["subnet"],
    "first_dhcp_ip"  = data.null_data_source.hostonly_network.outputs["first_dhcp_ip"],
    "last_dhcp_ip"   = data.null_data_source.hostonly_network.outputs["last_dhcp_ip"],
    "unused_segment" = data.null_data_source.hostonly_network.outputs["unused_segment"]
  }
}
