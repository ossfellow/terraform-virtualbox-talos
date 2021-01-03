module "talos" {
  controlplane_nodes      = ["akimiski"]
  kube_cluster_name       = "capi"
  dns_domain              = "example.com"
  kube_dns_domain         = "k8s.example.com"
  talos_version           = "v0.8.0"
  controlplane_scheduling = true
  os_installation_wait    = "210s"
  conf_dir                = "${path.root}/talos-config"
  admin_password          = var.admin_password
  controlplane_specs = {
    cpus      = 2
    ram_size  = 2048
    disk_size = 16000
  }

  source = "../../"
}
