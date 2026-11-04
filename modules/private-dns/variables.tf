variable "resource_group_name" {
  description = "Resource group that holds the zones created by this module."
  type        = string
  default     = null
}

variable "zone_names" {
  description = "Zones to create, e.g. privatelink.vaultcore.azure.net. Empty when only linking existing zones."
  type        = list(string)
  default     = []
}

variable "links" {
  description = "Link name => target zone and VNet. resource_group_name is the zone's resource group."
  type = map(object({
    zone_name           = string
    resource_group_name = string
    virtual_network_id  = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
