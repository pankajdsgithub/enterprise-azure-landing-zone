variable "name" {
  description = "e.g. pep-kv-app-dev-cin-001"
  type        = string
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

variable "target_resource_id" {
  type = string
}

variable "subresource_names" {
  description = "Group IDs: vault, blob, file, sqlServer, ..."
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Zone IDs for the DNS zone group (auto-registers the A record). Empty if DNS is managed by policy/central team."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
