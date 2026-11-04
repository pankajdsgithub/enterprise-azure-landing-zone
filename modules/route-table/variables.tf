variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "bgp_route_propagation_enabled" {
  description = "Set false on spoke tables so on-prem BGP routes cannot bypass the firewall."
  type        = bool
  default     = false
}

variable "routes" {
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.routes) : r.next_hop_type != "VirtualAppliance" || r.next_hop_in_ip_address != null])
    error_message = "next_hop_in_ip_address is required when next_hop_type is VirtualAppliance."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
