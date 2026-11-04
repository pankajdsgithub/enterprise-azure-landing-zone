variable "name" {
  description = "Firewall name, e.g. afw-hub-prd-cin-001."
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku_tier" {
  description = "Basic (cheapest, training), Standard or Premium. COST: Standard ~ USD 900+/month if left running."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Basic, Standard or Premium."
  }
}

variable "firewall_subnet_id" {
  description = "ID of AzureFirewallSubnet."
  type        = string
}

variable "management_subnet_id" {
  description = "ID of AzureFirewallManagementSubnet (Basic SKU only)."
  type        = string
  default     = null
}

variable "zones" {
  description = "Availability zones, e.g. [\"1\",\"2\",\"3\"] for production."
  type        = list(string)
  default     = []
}

variable "dns_proxy_enabled" {
  description = "Standard/Premium only. Enables DNS proxy so spokes can use the firewall as DNS server."
  type        = bool
  default     = true
}

variable "network_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      protocols             = list(string)
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
    }))
  }))
  default = {}
}

variable "application_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
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
