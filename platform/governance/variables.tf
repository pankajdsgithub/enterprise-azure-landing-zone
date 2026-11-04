variable "org_mg_name" {
  description = "Name (ID) of the organisation management group below Tenant Root."
  type        = string
  default     = "mg-contoso"
}

variable "allowed_locations" {
  type    = list(string)
  default = ["centralindia", "southindia", "global"]
}

variable "required_tags" {
  description = "Tags that must exist on every resource group (Deny)."
  type        = list(string)
  default     = ["environment", "owner", "costcenter", "workload"]
}

variable "policy_enforce" {
  description = "Set false for a dry run (DoNotEnforce): policies report but never block."
  type        = bool
  default     = true
}

variable "policy_assignment_location" {
  description = "Region for managed identities of Modify/DINE assignments."
  type        = string
  default     = "centralindia"
}

variable "subscription_associations" {
  description = "Subscription placement, e.g. { connectivity = { management_group = \"mg-connectivity\", subscription_id = \"<GUID>\" } }. Provide via tfvars/CI, never commit real IDs."
  type = map(object({
    management_group = string
    subscription_id  = string
  }))
  default = {}
}
