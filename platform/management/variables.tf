variable "location" {
  type    = string
  default = "centralindia"
}

variable "location_short" {
  type    = string
  default = "cin"
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "daily_quota_gb" {
  description = "Ingestion cap, cost guard-rail for training."
  type        = number
  default     = 1
}

variable "alert_email_receivers" {
  description = "Name => e-mail. Supplied via tfvars/CI variable, not committed."
  type        = map(string)
  default     = {}
}

variable "enable_activity_log" {
  type    = bool
  default = true
}

variable "defender_plans" {
  description = "Defender for Cloud plans to enable at Standard tier. COST: each plan is billed. Examples: VirtualMachines, StorageAccounts, KeyVaults, Arm, SqlServers. Empty = Foundational CSPM (free) only."
  type        = list(string)
  default     = []
}

variable "security_contact_email" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
  default = {
    environment = "platform"
    workload    = "management"
    owner       = "platform-team"
    costcenter  = "it-platform"
    managedby   = "terraform"
  }
}
