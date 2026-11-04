variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "storage_mode_type" {
  description = "LocallyRedundant (training) | ZoneRedundant | GeoRedundant (prod default)."
  type        = string
  default     = "LocallyRedundant"

  validation {
    condition     = contains(["LocallyRedundant", "ZoneRedundant", "GeoRedundant"], var.storage_mode_type)
    error_message = "Invalid storage_mode_type."
  }
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "backup_time" {
  type    = string
  default = "22:00"
}

variable "instant_restore_days" {
  type    = number
  default = 2
}

variable "daily_retention_count" {
  type    = number
  default = 7
}

variable "weekly_retention_count" {
  type    = number
  default = 0
}

variable "protected_vm_ids" {
  description = "Static key => VM resource ID. Keys must be known at plan time."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
