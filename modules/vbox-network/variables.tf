variable "hostonly_ipv4_subnet" {
  description = "IPv4 private subnet of the VirtualBox hostonly network"
  type        = string
  default     = ""

  validation {
    condition     = can(cidrnetmask(var.hostonly_ipv4_subnet)) && split("/", var.hostonly_ipv4_subnet)[1] == "16"
    error_message = "The specified hostonly IPv4 CIDR is invalid."
  }
}

variable "hostonly_ipv6_subnet" {
  description = "IPv6 private subnet of the VirtualBox hostonly network"
  type        = string
  default     = ""

  validation {
    condition     = can(cidrhost(var.hostonly_ipv6_subnet, 1)) && split("/", var.hostonly_ipv6_subnet)[1] == "64"
    error_message = "The specified hostonly IPv6 CIDR is invalid."
  }
}

variable "dhcp_min_lease_time" {
  description = "The minimum DHCP lease time, in seconds, for an assigned hostonly IP"
  type        = number
  default     = 0

  validation {
    condition     = var.dhcp_min_lease_time >= 86400
    error_message = "The specified minimum DHCP lease time is invalid."
  }
}

variable "dhcp_max_lease_time" {
  description = "The maximum DHCP lease time, in seconds, for an assigned hostonly IP"
  type        = number
  default     = 0

  validation {
    condition     = var.dhcp_max_lease_time >= 86400
    error_message = "The specified maximum DHCP lease time is invalid."
  }
}

variable "dhcp_default_lease_time" {
  description = "The default DHCP lease time, in seconds, for an assigned hostonly IP"
  type        = number
  default     = 0

  validation {
    condition     = var.dhcp_default_lease_time >= 86400
    error_message = "The specified default DHCP lease time is invalid."
  }
}

variable "dns_domain" {
  description = "The DNS domain for the hostonly network; usually the domain host is part of"
  type        = string
  default     = ""

  validation {
    condition     = var.dns_domain != ""
    error_message = "The specified DNS domain is invalid, or is empty."
  }
}

variable "remove_hostonlynet" {
  description = "Whether the VirtualBox hostonly network should be removed"
  type        = bool
  default     = false
}

variable "shell" {
  description = "The qualified name of preferred shell (e.g. /bin/bash, /bin/zsh, /bin/sh...), to minimize risk of incompatibility"
  type        = string
  default     = ""

  validation {
    condition     = var.shell != ""
    error_message = "The shell, for exection of scripts, must be identified."
  }
}
