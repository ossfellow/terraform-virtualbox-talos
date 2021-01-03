locals {
  talos_nodes = length(var.worker_nodes) > 0 ? concat(var.controlplane_nodes, var.worker_nodes) : var.controlplane_nodes
  # Terraform creates the VMs in parallel, and as a result, the order of returned VMs and IPs could be different from the input lists; so match IPs to input VM names
  talos_ips = length(var.worker_nodes) > 0 ? concat([for v in var.controlplane_nodes : module.controlplane_vms[v].vm_ip], [for v in var.worker_nodes : module.worker_vms[v].vm_ip]) : [for v in var.controlplane_nodes : module.controlplane_vms[v].vm_ip]

  controlplane_extrahosts = [
    for i in range(length(var.controlplane_nodes)) : [
      local.talos_ips[i],
      format("%s.%s", var.controlplane_nodes[i], var.dns_domain)
    ]
  ]

  worker_extrahosts = [
    for i in range(length(var.worker_nodes)) : [
      local.talos_ips[length(var.controlplane_nodes) + i],
      format("%s.%s", var.worker_nodes[i], var.dns_domain)
    ]
  ]

  scripts_dir = "${path.module}/scripts"
}

# Make sure Talos ISO and CLI are available for the selected version
resource "null_resource" "talos_download" {
  provisioner "local-exec" {
    interpreter = [var.shell, "-c"]
    command     = "${local.scripts_dir}/talos_download.sh"

    environment = {
      ISO_DIR         = abspath(var.conf_dir)
      TALOS_VERSION   = var.talos_version
      TALOSCTL_UPDATE = var.talos_cli_update
    }
  }
}

# Generate the Talos Machine (Ed25519), Kubernetes API server (RSA 4096) and etcd (RSA 4096) certificates
data "external" "talos_certificates" {
  program = [var.shell, "${local.scripts_dir}/talos_certificates.sh"]

  query = {
    conf_dir = abspath(var.conf_dir)
  }

  depends_on = [null_resource.talos_download]
}

# Generate the Talos PKI token, and Kubernetes bootstrap token
resource "random_string" "random_token" {
  count = 2

  length    = 35
  min_lower = 20
  upper     = false
  special   = false
}

# Generate the Kubernetes bootstrap data encryption key
resource "random_string" "random_key" {
  count  = 1
  length = 32
}

# Create a VirtualBox hostonly network, for Talos clusters
module "talos_network" {
  hostonly_ipv4_subnet    = var.hostonly_ipv4_subnet
  hostonly_ipv6_subnet    = var.hostonly_ipv6_subnet
  dhcp_min_lease_time     = var.dhcp_min_lease_time
  dhcp_max_lease_time     = var.dhcp_max_lease_time
  dhcp_default_lease_time = var.dhcp_default_lease_time
  dns_domain              = var.dns_domain
  remove_hostonlynet      = var.remove_hostonlynet
  shell                   = var.shell

  source = "./modules/vbox-network"
}

# Launch the VirtualBox VMs, used for Talos cluster control plane nodes
module "controlplane_vms" {
  for_each = toset(var.controlplane_nodes)

  vm_name            = each.key
  vm_specs           = var.controlplane_specs
  os_iso             = "${abspath(var.conf_dir)}/talos.iso"
  ip_assignment_wait = var.ip_assignment_wait
  mac_address_prefix = var.mac_address_prefix
  bridge_adapter     = module.talos_network.bridge_adapter
  hostonly_network   = module.talos_network.hostonly_network["name"]
  host_dns_access    = var.host_dns_access
  chipset            = var.chipset
  vm_frontend_style  = var.vm_frontend_style
  boottime_config    = var.boottime_config
  vbox_group         = var.vbox_group
  vm_description     = var.vm_description
  admin_password     = var.admin_password
  node_fqdn          = format("%s.%s", each.key, var.dns_domain)
  shell              = var.shell
  node_alias         = format("%s.%s", var.kube_cluster_name, var.dns_domain)
  #node_alias         = index(var.controlplane_nodes, each.key) == 0 ? format("%s.%s", var.kube_cluster_name, var.dns_domain) : ""

  source = "./modules/vbox-vm"

  depends_on = [module.talos_network]
}

# Launch the VirtualBox VMs, used for Talos cluster worker nodes
module "worker_vms" {
  for_each = toset(var.worker_nodes)

  vm_name            = each.key
  vm_specs           = var.worker_specs
  os_iso             = "${abspath(var.conf_dir)}/talos.iso"
  ip_assignment_wait = var.ip_assignment_wait
  mac_address_prefix = var.mac_address_prefix
  bridge_adapter     = module.talos_network.bridge_adapter
  hostonly_network   = module.talos_network.hostonly_network["name"]
  host_dns_access    = var.host_dns_access
  chipset            = var.chipset
  vm_frontend_style  = var.vm_frontend_style
  boottime_config    = var.boottime_config
  vbox_group         = var.vbox_group
  vm_description     = var.vm_description
  admin_password     = var.admin_password
  node_fqdn          = format("%s.%s", each.key, var.dns_domain)
  shell              = var.shell
  node_alias         = ""

  source = "./modules/vbox-vm"

  # The dependency on controlplane_vms module is not necessary, but makes Ip assignments clearer
  depends_on = [module.talos_network, module.controlplane_vms]
}

# Generate the talosconfig file
resource "local_file" "talosconfig" {
  content = templatefile("${path.module}/talosconfig.tpl", {
    tf_cluster_name    = var.kube_cluster_name
    tf_endpoints       = slice(local.talos_ips, 0, length(var.controlplane_nodes))
    tf_talos_ca_crt    = data.external.talos_certificates.result.talos_crt
    tf_talos_admin_crt = data.external.talos_certificates.result.admin_crt
    tf_talos_admin_key = data.external.talos_certificates.result.admin_key
  })
  filename = "${abspath(var.conf_dir)}/talosconfig"

  depends_on = [data.external.talos_certificates]
}

# Generate the Talos controlplane.yaml files
resource "local_file" "controlplane_config" {
  for_each = toset(var.controlplane_nodes)

  content = templatefile("${path.module}/taloscontrolplane.tpl", {
    tf_talos_token      = format("%s.%s", substr(random_string.random_token[0].result, 7, 6), substr(random_string.random_token[0].result, 17, 16))
    tf_type             = index(var.controlplane_nodes, each.key) == 0 ? "init" : "controlplane"
    tf_talos_ca_crt     = data.external.talos_certificates.result.talos_crt
    tf_talos_ca_key     = data.external.talos_certificates.result.talos_key
    tf_host_arch        = data.external.talos_certificates.result.host_arch
    tf_kube_version     = var.kube_version
    tf_hostname         = each.key
    tf_node_fqdn        = format("%s.%s", each.key, var.dns_domain)
    tf_cp_extrahosts    = local.controlplane_extrahosts
    tf_wk_extrahosts    = local.worker_extrahosts
    tf_talos_version    = var.talos_version
    tf_cluster_endpoint = format("%s.%s", var.kube_cluster_name, var.dns_domain)
    tf_cluster_name     = var.kube_cluster_name
    tf_kube_dns_domain  = var.kube_dns_domain
    tf_kube_token       = format("%s.%s", substr(random_string.random_token[1].result, 5, 6), substr(random_string.random_token[1].result, 15, 16))
    tf_kube_enc_key     = base64encode(random_string.random_key[0].result)
    tf_kube_ca_crt      = data.external.talos_certificates.result.kube_crt
    tf_kube_ca_key      = data.external.talos_certificates.result.kube_key
    tf_etcd_ca_crt      = data.external.talos_certificates.result.etcd_crt
    tf_etcd_ca_key      = data.external.talos_certificates.result.etcd_key
    tf_allow_scheduling = var.controlplane_scheduling
  })
  filename = "${abspath(var.conf_dir)}/${each.key}.yaml"

  depends_on = [module.controlplane_vms, data.external.talos_certificates, random_string.random_token, random_string.random_key]
}

# Generate the Talos worker.yaml files
resource "local_file" "worker_config" {
  for_each = toset(var.worker_nodes)

  content = templatefile("${path.module}/talosworker.tpl", {
    tf_talos_token      = format("%s.%s", substr(random_string.random_token[0].result, 7, 6), substr(random_string.random_token[0].result, 17, 16))
    tf_type             = "worker"
    tf_host_arch        = data.external.talos_certificates.result.host_arch
    tf_kube_version     = var.kube_version
    tf_hostname         = each.key
    tf_node_fqdn        = format("%s.%s", each.key, var.dns_domain)
    tf_cp_extrahosts    = local.controlplane_extrahosts
    tf_wk_extrahosts    = local.worker_extrahosts
    tf_talos_version    = var.talos_version
    tf_cluster_endpoint = format("%s.%s", var.kube_cluster_name, var.dns_domain)
    tf_kube_dns_domain  = var.kube_dns_domain
    tf_kube_token       = format("%s.%s", substr(random_string.random_token[1].result, 5, 6), substr(random_string.random_token[1].result, 15, 16))
    tf_kube_ca_crt      = data.external.talos_certificates.result.kube_crt
  })
  filename = "${abspath(var.conf_dir)}/${each.key}.yaml"

  depends_on = [module.controlplane_vms, module.worker_vms, data.external.talos_certificates, random_string.random_token]
}

# Provide the Talos configuration yaml files, to the newly booted up VirtualBox VMs
resource "null_resource" "os_install" {
  count = length(local.talos_nodes)

  provisioner "local-exec" {
    interpreter = [var.shell, "-c"]
    command     = <<-EOT
      sleep $APPLY_PAUSE
      talosctl apply-config --insecure --nodes $NODE_IP --file $NODE_CONFIG
    EOT

    environment = {
      APPLY_PAUSE = var.apply_config_wait * count.index
      NODE_IP     = local.talos_ips[count.index]
      NODE_CONFIG = "${abspath(var.conf_dir)}/${local.talos_nodes[count.index]}.yaml"
    }
  }

  depends_on = [local_file.controlplane_config, local_file.worker_config]
}

# Wait until Talos cluster nodes (controlplane or worker) are configured
resource "time_sleep" "os_install_wait" {
  count = length(local.talos_nodes)

  create_duration = var.os_installation_wait

  depends_on = [null_resource.os_install]
}

# Update the kubeconfig
resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    interpreter = [var.shell, "-c"]
    command     = "talosctl --talosconfig $TALOSCONFIG -e $NODE_IP -n $NODE_IP kubeconfig --force --force-context-name $CLUSTER_NAME"
    on_failure  = continue

    environment = {
      CLUSTER_NAME = var.kube_cluster_name
      NODE_IP      = local.talos_ips[0]
      TALOSCONFIG  = "${abspath(var.conf_dir)}/talosconfig"
    }
  }

  depends_on = [time_sleep.os_install_wait]
}

# Remove the cluster, context, and user of Talos cluster, in kubeconfig
resource "null_resource" "clean_kubeconfig" {
  for_each = toset([format("%s|%s", var.shell, var.kube_cluster_name)])

  provisioner "local-exec" {
    when        = destroy
    interpreter = [tostring(split("|", each.key)[0])]
    command     = <<-EOT
      kubectl config delete-cluster $CLUSTER_NAME
      kubectl config delete-context $CLUSTER_NAME
      kubectl config unset users.admin@$CLUSTER_NAME
    EOT
    on_failure  = continue

    environment = {
      CLUSTER_NAME = split("|", each.key)[1]
    }
  }
}
