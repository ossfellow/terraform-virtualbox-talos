variable "controlplane_nodes" {
  description = "The list of Talos control plane nodes (either 1 or 3 nodes); the first node is used for initializing the cluster"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.controlplane_nodes) == 1 || length(var.controlplane_nodes) == 3
    error_message = "Number of control plane nodes must be either one, or three (HA cluster)."
  }
}

variable "controlplane_specs" {
  description = "The VirtualBox VM specs used for building Talos cluster's control plane nodes (default is 2 CPU, 2GB RAM, and 8GB disk)"
  type = object({
    cpus      = number
    ram_size  = number
    disk_size = number
  })
  default = {
    cpus      = 2
    ram_size  = 2048
    disk_size = 8000
  }
}

variable "worker_nodes" {
  description = "The list of Talos worker nodes (minimum is 0 nodes); the maximum depends on availability of host resources"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.worker_nodes) >= 0
    error_message = "Number of worker nodes must be zero or more."
  }
}

variable "worker_specs" {
  description = "The VirtualBox VM specs used for building Talos cluster's worker nodes (default is 2 CPU, 2GB RAM, and 8GB disk)"
  type = object({
    cpus      = number
    ram_size  = number
    disk_size = number
  })
  default = {
    cpus      = 2
    ram_size  = 2048
    disk_size = 8000
  }
}

variable "talos_version" {
  description = "The version of Talos OS, used for building the cluster; the version string should start with 'v'"
  type        = string
  default     = ""

  validation {
    condition     = var.talos_version != "" && substr(var.talos_version, 0, 1) == "v"
    error_message = "The specified Talos version is invalid."
  }
}

variable "talos_cli_update" {
  description = "Whether Talos CLI (talosctl) should be installed/updated or not, for the specified Talos version (default is true)"
  type        = bool
  default     = true
}

variable "kube_version" {
  description = "The version of Kubernetes (e.g. 1.20); default is the latest version supported by the selected Talos version"
  type        = string
  default     = ""
}

variable "kube_cluster_name" {
  description = "The Kubernetes cluster name (default is talos)"
  type        = string
  default     = "talos"

  validation {
    condition     = var.kube_cluster_name != ""
    error_message = "The Kubernetes cluster name must be identified."
  }
}

variable "kube_dns_domain" {
  description = "The Kubernetes cluster DNS domain (default is cluster.local)"
  type        = string
  default     = "cluster.local"

  validation {
    condition     = var.kube_dns_domain != ""
    error_message = "The Kubernetes cluster DNS domain must be identified."
  }
}

variable "controlplane_scheduling" {
  description = "Whether the scheduling taint of the Talos cluster control plane nodes should be removed (default is false)"
  type        = bool
  default     = false
}

variable "apply_config_wait" {
  description = "Whether Talos CLI's apply-config should be applied sequentially, by a number of seconds; can ease pressure on host resources (default is 0s)"
  type        = number
  default     = 0

  validation {
    condition     = var.apply_config_wait >= 0
    error_message = "The specified apply config wait time is invalid."
  }
}

variable "os_installation_wait" {
  description = "How long Terraform should wait for OS installation; it's host resources, network bandwidth, and image caching dependent (default is 4m)"
  type        = string
  default     = "4m"

  validation {
    condition     = var.os_installation_wait != ""
    error_message = "The specified OS installation wait time is invalid."
  }
}

variable "conf_dir" {
  description = "The directory used for storing Talos ISO and cluster build configuration files (default is /tmp)"
  type        = string
  default     = "/tmp"

  validation {
    condition     = var.conf_dir != ""
    error_message = "The Talos configuration directory must be identified."
  }
}

variable "shell" {
  description = "The qualified name of preferred shell (e.g. /bin/bash, /bin/zsh, /bin/sh...), to minimize risk of incompatibility (default is /bin/bash)"
  type        = string
  default     = "/bin/bash"

  validation {
    condition     = var.shell != ""
    error_message = "The shell, for exection of scripts, must be identified."
  }
}
