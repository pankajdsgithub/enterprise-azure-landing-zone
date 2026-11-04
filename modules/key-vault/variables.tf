variable "name" {
  description = "Globally unique, 3-24 chars."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 chars, start with a letter, alphanumerics and hyphens only."
  }
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "purge_protection_enabled" {
  description = "Irreversible once enabled. Use true in prod; false in training so names can be reused after destroy."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention must be 7-90 days."
  }
}

variable "public_network_access_enabled" {
  description = "Secure default false: reach the vault via Private Endpoint only. Terraform cannot manage secrets from outside the network when false."
  type        = bool
  default     = false
}

variable "allowed_ip_rules" {
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

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
