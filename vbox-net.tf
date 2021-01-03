variable "hostonly_ipv4_subnet" {
  description = "The private IPv4 subnet of the VirtualBox hostonly network (default is 172.27.0.0/16)"
  type        = string
  default     = "172.27.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.hostonly_ipv4_subnet)) && split("/", var.hostonly_ipv4_subnet)[1] == "16"
    error_message = "The specified hostonly IPv4 CIDR is invalid."
  }
}

variable "hostonly_ipv6_subnet" {
  description = "The private IPv6 subnet of the VirtualBox hostonly network (default is fd67:27::/64)"
  type        = string
  default     = "fd67:27::/64"

  validation {
    condition     = can(cidrhost(var.hostonly_ipv6_subnet, 1)) && split("/", var.hostonly_ipv6_subnet)[1] == "64"
    error_message = "The specified hostonly IPv6 CIDR is invalid."
  }
}

variable "dhcp_min_lease_time" {
  description = "The minimum DHCP lease time, in seconds, for an assigned hostonly IP (default is 1 month)"
  type        = number
  default     = 2629800

  validation {
    condition     = var.dhcp_min_lease_time >= 86400
    error_message = "The specified minimum DHCP lease time is invalid."
  }
}

variable "dhcp_max_lease_time" {
  description = "The maximum DHCP lease time, in seconds, for an assigned hostonly IP (default is 5 year)"
  type        = number
  default     = 157788000

  validation {
    condition     = var.dhcp_max_lease_time >= 86400
    error_message = "The specified maximum DHCP lease time is invalid."
  }
}

variable "dhcp_default_lease_time" {
  description = "The default DHCP lease time, in seconds, for an assigned hostonly IP (default is 3 year)"
  type        = number
  default     = 94672800

  validation {
    condition     = var.dhcp_default_lease_time >= 86400
    error_message = "The specified default DHCP lease time is invalid."
  }
}

variable "dns_domain" {
  description = "The DNS domain for the hostonly network; usually the domain host is part of (default is example.com)"
  type        = string
  default     = "example.com"

  validation {
    condition     = var.dns_domain != ""
    error_message = "The specified DNS domain is invalid, or is empty."
  }
}

variable "remove_hostonlynet" {
  description = "Whether the VirtualBox hostonly network, dedicated to Talos clusters, should be removed (default is false)"
  type        = bool
  default     = false
}
