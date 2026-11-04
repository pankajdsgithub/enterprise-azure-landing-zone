variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "rules" {
  description = "Rule name => definition. Default Azure rules (AllowVNetInBound etc.) still apply below priority 65000."
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    destination_port_ranges      = list(string)
    source_address_prefixes      = list(string)
    destination_address_prefixes = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.rules) : r.priority >= 100 && r.priority <= 4096])
    error_message = "Rule priority must be between 100 and 4096."
  }

  validation {
    condition     = alltrue([for r in values(var.rules) : contains(["Inbound", "Outbound"], r.direction) && contains(["Allow", "Deny"], r.access)])
    error_message = "direction must be Inbound/Outbound and access must be Allow/Deny."
  }
}

variable "log_analytics_workspace_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
