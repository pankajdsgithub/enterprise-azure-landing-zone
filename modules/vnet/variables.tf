variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type = list(string)

  validation {
    condition     = alltrue([for c in var.address_space : can(cidrhost(c, 0))])
    error_message = "address_space must contain valid CIDR blocks."
  }
}

variable "dns_servers" {
  description = "Custom DNS servers (e.g. Azure Firewall DNS proxy IP). Empty = Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Map of subnet name => settings. Special names (AzureFirewallSubnet, GatewaySubnet, AzureBastionSubnet) must be used verbatim."
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Enabled")
    default_outbound_access_enabled   = optional(bool)
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
  }))
}

variable "nsg_associations" {
  description = "Subnet name => NSG ID. Do NOT associate NSGs to AzureFirewallSubnet or GatewaySubnet."
  type        = map(string)
  default     = {}
}

variable "route_table_associations" {
  description = "Subnet name => route table ID."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
