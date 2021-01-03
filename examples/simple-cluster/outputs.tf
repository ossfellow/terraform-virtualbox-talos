output "bridge_adapter" {
  description = "Host's first active bridge adapter"
  value       = module.talos.bridge_adapter
}

output "hostonly_network" {
  description = "Useful information about the VirtualBox hostonly network configuration"
  value       = module.talos.hostonly_network
}

output "talos_cluster" {
  description = "The hostname and hostonly IP address of Talos cluster nodes"
  value       = merge(module.talos.controlplane_nodes, module.talos.worker_nodes)
}
