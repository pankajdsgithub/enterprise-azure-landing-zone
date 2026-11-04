variable "location" {
  type    = string
  default = "centralindia"
}

variable "location_short" {
  type    = string
  default = "cin"
}

variable "org" {
  description = "Short organisation code used in names."
  type        = string
  default     = "contoso"
}

variable "hub_address_space" {
  type    = list(string)
  default = ["10.0.0.0/23"]
}

variable "enable_firewall" {
  description = "COST: Azure Firewall bills hourly. Default false for training."
  type        = bool
  default     = false
}

variable "firewall_sku_tier" {
  type    = string
  default = "Basic"
}

variable "enable_bastion" {
  description = "COST: Bastion bills hourly. Default false."
  type        = bool
  default     = false
}

variable "private_dns_zones" {
  description = "Private DNS zones for Private Link, created once in the hub (central DNS)."
  type        = list(string)
  default = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.database.windows.net",
  ]
}

variable "spoke_address_spaces" {
  description = "All spoke CIDRs; used for firewall rules (spoke-to-spoke policy)."
  type        = map(string)
  default = {
    dev  = "10.10.0.0/22"
    qa   = "10.20.0.0/22"
    prod = "10.30.0.0/22"
  }
}

variable "log_analytics_workspace_id" {
  description = "Central workspace ID from platform/management (null on first run)."
  type        = string
  default     = null
}

variable "tags" {
  type = map(string)
  default = {
    environment = "platform"
    workload    = "connectivity"
    owner       = "network-team"
    costcenter  = "it-platform"
    managedby   = "terraform"
  }
}
