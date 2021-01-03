# Simple cluster

This example builds a Talos Kubernetes cluster, with one control plane and two worker nodes, using the following options:

| Input variable | Description | Value |
|---------|----------|---------|
| controlplane_nodes | List of Talos control plane nodes; these will be used as hostnames | ["nuna"] |
| worker_nodes | List of Talos worker nodes; these will be used as hostnames | ["akpatok", "kitlineq"] |
| dns_domain | local network domain | example.com |
| kube_cluster_name | Kubernetes cluster name | gitops |
| kube_dns_doamin | Kubernetes cluster domain | k8s.example.com |
| talos_version | Talos release version | v0.8.0 |
| shell | Preferred shell for execution of scripts | /bin/zsh |
| conf_dir | Where Talos ISO and cluster configuration files should be stored | ./talos-config |
| admin_password | User password required for updating /etc/hosts | TF_VAR_admin_password (environment variable) |

> The ability to update hosts's /etc/hosts file is useful for kubectl's immediate access to the cluster.

>The default configuration starts VirtualBox VMs, as headless, so the VM GUI is not shown. If desired, this could be altered by changing the _vm_frontend_style_ variable or accessing the GUI through VirtualBox console.

The output of successful execution would include:

- The name of host bridge adapter used
- Configuration information of the hostonly network, used by the cluster
- Name and hostonly IP addresses (i.e. Talos node IP) of all VMs
