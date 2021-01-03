output "vm_name" {
  description = "The VirtualBox VM name"
  value       = var.vm_name
}

output "vm_ip" {
  description = "The hostonly network assigned IP address of the VirtualBox VM"
  value       = data.external.hostonly_network.result.vm_ip
}
