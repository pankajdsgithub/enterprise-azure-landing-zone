variable "server_name" {
  description = "Globally unique logical server name."
  type        = string
}

variable "database_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "entra_admin_login" {
  description = "Display name / UPN of the Entra ID admin (prefer a group)."
  type        = string
}

variable "entra_admin_object_id" {
  description = "Object ID of the Entra ID admin group or user."
  type        = string
}

variable "sku_name" {
  description = "Basic / S0 for training; GP_Gen5_2 or higher for production."
  type        = string
  default     = "Basic"
}

variable "max_size_gb" {
  type    = number
  default = 2
}

variable "zone_redundant" {
  description = "Only supported on some SKUs (e.g. General Purpose / Premium). Extra cost."
  type        = bool
  default     = false
}

variable "pitr_retention_days" {
  type    = number
  default = 7
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
