# High availability cluster

This example builds a Talos Kubernetes cluster, with three control plane and one worker nodes, using the following options:

| Input variable | Description | Value |
|---------|----------|---------|
| controlplane_nodes | List of Talos control plane nodes; these will be used as hostnames | ["arviliit", "tujjaat", "ilulliq"] |
| worker_nodes | List of Talos worker nodes; these will be used as hostnames | ["nunaat"] |
| dns_domain | local network domain | example.com |
| kube_cluster_name | Kubernetes cluster name | raft |
| kube_dns_doamin | Kubernetes cluster domain | k8s.example.com |
| talos_version | Talos release version | v0.8.0 |
| os_installation_wait | Execution pause till completion  of Talos cluster installation and configuration | 5m |
| shell | Preferred shell for execution of scripts | /bin/sh |
| conf_dir | Where Talos ISO and cluster configuration files should be stored | ./talos-config |
| host_dns_access | Whether VMs could access host's /etc/hosts | true |
| admin_password | User password required for updating /etc/hosts | TF_VAR_admin_password (environment variable) |

> Although IP and DNS endpoint information is statically added to cluster nodes configuration (using extraHosts), access to endpoint information in hosts's /etc/hosts file is required for HA cluster setup, at the moment. This should be paired with providing the user password.

>The ability to update hosts's /etc/hosts file is useful for kubectl's immediate access to the cluster.

>The default configuration starts VirtualBox VMs, as headless, so the VM GUI is not shown. If desired, this could be altered by changing the _vm_frontend_style_ variable or accessing the GUI through VirtualBox console.

The output of successful execution would include:

- The name of host bridge adapter used
- Configuration information of the hostonly network, used by the cluster
- Name and hostonly IP addresses (i.e. Talos node IP) of all VMs

## Warning

Attempting to build a HA cluster could often cause [_etcdserver: Peer URLs already exists_](https://github.com/etcd-io/etcd/blob/master/api/v3rpc/rpctypes/error.go) error in the second and third control plane nodes. I could not identify a set of configuration values, which could eliminate or decrease the probability of this problem. If you tried this and could find the root cause, or how this could be done more reliably, please open an issue and share it.
