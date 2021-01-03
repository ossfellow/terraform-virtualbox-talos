module "talos" {
  controlplane_nodes = ["nuna"]
  worker_nodes       = ["akpatok", "kitlineq"]
  kube_cluster_name  = "gitops"
  dns_domain         = "example.com"
  kube_dns_domain    = "k8s.example.com"
  talos_version      = "v0.8.0"
  conf_dir           = "${path.root}/talos-config"
  admin_password     = var.admin_password
  shell              = "/bin/zsh"

  source = "../../"
}
