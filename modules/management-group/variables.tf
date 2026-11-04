variable "root_parent_id" {
  description = "Resource ID of the parent for level-1 groups. null = Tenant Root Group."
  type        = string
  default     = null
}

variable "level1" {
  description = "Top-level groups below root, e.g. the organisation group."
  type        = map(object({ display_name = string }))
  default     = {}
}

variable "level2" {
  description = "Second-level groups. parent = key in level1."
  type        = map(object({ display_name = string, parent = string }))
  default     = {}

  validation {
    condition     = alltrue([for v in values(var.level2) : contains(keys(var.level1), v.parent)])
    error_message = "Every level2 parent must be a key of level1."
  }
}

variable "level3" {
  description = "Third-level groups. parent = key in level2."
  type        = map(object({ display_name = string, parent = string }))
  default     = {}

  validation {
    condition     = alltrue([for v in values(var.level3) : contains(keys(var.level2), v.parent)])
    error_message = "Every level3 parent must be a key of level2."
  }
}

variable "subscription_associations" {
  description = "Map of arbitrary key => { management_group, subscription_id }. Subscription GUIDs come from tfvars/CI variables, never hardcoded in modules."
  type = map(object({
    management_group = string
    subscription_id  = string
  }))
  default = {}
}
