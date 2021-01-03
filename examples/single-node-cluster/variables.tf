variable "admin_password" {
  description = "The password of a privileged user, for updating /etc/hosts"
  type        = string
  default     = "!"
  sensitive   = false

  validation {
    condition     = var.admin_password != ""
    error_message = "The admin password is required for updating protected files (e.g. /etc/hosts)."
  }
}

