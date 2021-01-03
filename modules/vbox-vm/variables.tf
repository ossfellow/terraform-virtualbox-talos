variable "vm_name" {
  description = "The name of VirtualBox VM, which will be built"
  type        = string
  default     = ""

  validation {
    condition     = var.vm_name != ""
    error_message = "The VirtualBox VM name must be identified."
  }
}

variable "vm_specs" {
  description = "The VirtualBox VM specs used for building it"
  type = object({
    cpus      = number
    ram_size  = number
    disk_size = number
  })
}

variable "os_iso" {
  description = "The name and path of the OS ISO image used for building the VirtualBox VM"
  type        = string
  default     = ""

  validation {
    condition     = var.os_iso != ""
    error_message = "The OS ISO must be identified."
  }
}

variable "ip_assignment_wait" {
  description = "How long Terraform should wait, before querying the hostonly network's DHCP server, for the new VM's IP address"
  type        = string
  default     = ""

  validation {
    condition     = var.ip_assignment_wait != ""
    error_message = "The provided OS bootstrap wait time is invalid."
  }
}

variable "mac_address_prefix" {
  description = "The MAC address prefix used; the value cannot be arbitrary and must be recognized by VirtualBox"
  type        = string
  default     = ""

  validation {
    condition     = var.mac_address_prefix != ""
    error_message = "The VirtualBox MAC address prefix must be identified."
  }
}

variable "bridge_adapter" {
  description = "Host's first active bridge adapter"
  type        = string
  default     = ""

  validation {
    condition     = var.bridge_adapter != ""
    error_message = "The bridge adapter name must be identified."
  }
}

variable "hostonly_network" {
  description = "The name of VirtualBox hostonly network, used for VM build"
  type        = string
  default     = ""

  validation {
    condition     = var.hostonly_network != ""
    error_message = "The VirtualBox hostonly network must be identified."
  }
}

variable "host_dns_access" {
  description = "Whether the VirtualBox VM could access the host local DNS (/etc/hosts), via a NAT interface"
  type        = bool
  default     = false
}

variable "chipset" {
  description = "The motherboard chipset emulation used, for the VirtualBox VMs; valid values: piix3, and ich9"
  type        = string
  default     = ""

  validation {
    condition     = contains(["piix3", "ich9"], lower(var.chipset))
    error_message = "The selected chipset type is invalid, or not supported."
  }
}

variable "vm_frontend_style" {
  description = "The type of frontend used by VirtualBox, for launching the VM; valid types are: headless, gui, and separate"
  type        = string
  default     = ""

  validation {
    condition     = contains(["headless", "gui", "separate"], lower(var.vm_frontend_style))
    error_message = "The selected VirtualBox VM frontend type is invalid, or not supported."
  }
}

variable "boottime_config" {
  description = "Whether the VBox VM should autostart, when the host is rebooted"
  type = object({
    autostart       = string
    autostart_delay = number
  })

  validation {
    condition     = contains(["on", "off"], lower(var.boottime_config.autostart))
    error_message = "The selected VirtualBox VM's autostart behaviour, after host boot, is invalid, or not supported."
  }
}

variable "vbox_group" {
  description = "An optional VirtualBox group (i.e. a subdirectory), used for storing VM disk and snapshots"
  type        = string
  default     = ""
}

variable "vm_description" {
  description = "An optional description for the VirtualBox VM"
  type        = string
  default     = ""
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

variable "admin_password" {
  description = "The password of a privileged user, for updating /etc/hosts"
  type        = string
  default     = ""
  sensitive   = false
}

variable "node_fqdn" {
  description = "The VirtualBox VM's fqdn, to be added to /etc/hosts"
  type        = string
  default     = ""
}

variable "node_alias" {
  description = "The VirtualBox VM's alias (e.g. cluster endpoint), to be added to /etc/hosts"
  type        = string
  default     = ""
}
