variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "size" {
  description = "Training default is a burstable B-series. Use D-series / zonal in production."
  type        = string
  default     = "Standard_B2s"
}

variable "zone" {
  description = "Availability Zone (\"1\",\"2\",\"3\") or null."
  type        = string
  default     = null
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "admin_ssh_public_key" {
  description = "Public SSH key (e.g. file(\"~/.ssh/id_rsa.pub\")). Never pass a private key."
  type        = string
}

variable "os_disk_storage_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "encryption_at_host_enabled" {
  description = "Requires the EncryptionAtHost feature registered on the subscription."
  type        = bool
  default     = false
}

variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}

variable "attach_to_load_balancer" {
  description = "Explicit boolean (not derived from the pool ID) so count is known at plan time."
  type        = bool
  default     = false
}

variable "load_balancer_backend_pool_id" {
  type    = string
  default = null
}

variable "install_monitor_agent" {
  type    = bool
  default = false
}

variable "associate_data_collection_rule" {
  type    = bool
  default = false
}

variable "data_collection_rule_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
