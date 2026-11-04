variable "name" {
  description = "Globally unique, 3-24 lowercase alphanumerics."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase letters and digits."
  }
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "replication_type" {
  description = "LRS (training) | ZRS | GRS | GZRS (prod)."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGRS", "RAGZRS"], var.replication_type)
    error_message = "Invalid replication type."
  }
}

variable "shared_access_key_enabled" {
  description = "false = Entra ID auth only (recommended)."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "infrastructure_encryption_enabled" {
  description = "Double encryption at rest. Must be set at creation time."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "soft_delete_days" {
  type    = number
  default = 7
}

variable "allowed_ip_rules" {
  type    = list(string)
  default = []
}

variable "containers" {
  type    = list(string)
  default = []
}

variable "role_assignments" {
  type = map(object({
    role         = string
    principal_id = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
