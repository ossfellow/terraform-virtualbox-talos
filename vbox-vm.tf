variable "vm_specs" {
  description = "The default specs used for building a VirtualBox VM (default is 2 CPU, 2GB RAM, and 8GB disk)"
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

variable "ip_assignment_wait" {
  description = "How long Terraform should wait, before querying the hostonly network's DHCP server, for the new VM's IP address (default is 20s)"
  type        = string
  default     = "20s"

  validation {
    condition     = var.ip_assignment_wait != ""
    error_message = "The provided OS bootstrap wait time is invalid."
  }
}

variable "mac_address_prefix" {
  description = "The MAC address prefix used; the value cannot be arbitrary and must be recognized by VirtualBox (default is 080027)"
  type        = string
  default     = "080027"

  validation {
    condition     = var.mac_address_prefix != ""
    error_message = "The VirtualBox MAC address prefix must be identified."
  }
}

variable "bridge_adapter_override" {
  description = "Use this bridge adapter, instead of host's first active one; the name should match an active host bridge adapter, as seen using << VBoxManage list bridgedifs >>"
  type        = string
  default     = ""
}

variable "host_dns_access" {
  description = "Whether the VirtualBox VM could access the host local DNS (/etc/hosts), via a NAT interface (default is false)"
  type        = bool
  default     = false
}

variable "chipset" {
  description = "The motherboard chipset emulation used, for the VirtualBox VMs; valid values: piix3, and ich9 (default is piix3)"
  type        = string
  default     = "piix3"

  validation {
    condition     = contains(["piix3", "ich9"], lower(var.chipset))
    error_message = "The selected chipset type is invalid, or not supported."
  }
}

variable "vm_frontend_style" {
  description = "The type of frontend used by VirtualBox, for launching the VM; valid types are: headless, gui, and separate (default is headless)"
  type        = string
  default     = "headless"

  validation {
    condition     = contains(["headless", "gui", "separate"], lower(var.vm_frontend_style))
    error_message = "The selected VirtualBox VM frontend type is invalid, or not supported."
  }
}

variable "boottime_config" {
  description = "Whether the VBox VM should autostart, when the host is rebooted (default is off)"
  type = object({
    autostart       = string
    autostart_delay = number
  })
  default = {
    autostart       = "off"
    autostart_delay = 300
  }

  validation {
    condition     = contains(["on", "off"], lower(var.boottime_config.autostart))
    error_message = "The selected VirtualBox VM's autostart behaviour, after host boot, is invalid, or not supported."
  }
}

variable "vbox_group" {
  description = "An optional VirtualBox group (i.e. a subdirectory), used for storing VM disk and snapshots (default is Talos)"
  type        = string
  default     = "Talos"
}

variable "vm_description" {
  description = "An optional description for the VirtualBox VM"
  type        = string
  default     = "Talos, a secure, immutable, and minimal OS, for hosting Kubernetes"
}

variable "admin_password" {
  description = "The password of a privileged user, for updating /etc/hosts (default is !)"
  type        = string
  default     = "!"
  sensitive   = false

  validation {
    condition     = var.admin_password != ""
    error_message = "The admin password is required for updating protected files (e.g. /etc/hosts)."
  }
}

