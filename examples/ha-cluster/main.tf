module "talos" {
  controlplane_nodes   = ["arviliit", "tujjaat", "ilulliq"]
  worker_nodes         = ["nunaat"]
  kube_cluster_name    = "raft"
  dns_domain           = "example.com"
  kube_dns_domain      = "k8s.example.com"
  talos_version        = "v0.8.0"
  os_installation_wait = "5m"
  conf_dir             = "${path.root}/talos-config"
  host_dns_access      = true
  admin_password       = var.admin_password
  shell                = "/bin/sh"

  source = "../../"
}
