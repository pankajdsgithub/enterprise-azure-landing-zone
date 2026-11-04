variable "name" {
  description = "e.g. peer-hub-to-dev"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group of the LOCAL virtual network."
  type        = string
}

variable "virtual_network_name" {
  description = "LOCAL virtual network name."
  type        = string
}

variable "remote_virtual_network_id" {
  type = string
}

variable "allow_forwarded_traffic" {
  description = "Must be true on both sides when traffic is routed via a firewall (NVA)."
  type        = bool
  default     = true
}

variable "allow_gateway_transit" {
  description = "Hub side only: let spokes use the hub VPN/ER gateway."
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Spoke side only: use the hub gateway. Requires the hub gateway to exist first."
  type        = bool
  default     = false
}
