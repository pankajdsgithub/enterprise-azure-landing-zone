variable "location" {
  type    = string
  default = "centralindia"
}

variable "resource_group_name" {
  type    = string
  default = "rg-tfstate-mgmt-cin-001"
}

variable "storage_account_name" {
  description = "Globally unique, 3-24 lowercase alphanumerics, e.g. sttfstatecin<random5>."
  type        = string
}

variable "state_containers" {
  description = "One container per state boundary => isolation between environments and layers."
  type        = list(string)
  default     = ["tfstate-platform", "tfstate-dev", "tfstate-qa", "tfstate-prod"]
}

variable "allowed_ip_rules" {
  description = "Public IPv4 addresses allowed to reach the state account (your workstation / self-hosted agent NAT IP)."
  type        = list(string)
  default     = []
}

variable "additional_state_contributor_object_ids" {
  description = "Object IDs (CI service principal / managed identity) that need Storage Blob Data Contributor."
  type        = map(string)
  default     = {}
}

variable "enable_delete_lock" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    workload    = "terraform-state"
    environment = "platform"
    owner       = "platform-team"
    costcenter  = "it-platform"
    managedby   = "terraform"
  }
}
