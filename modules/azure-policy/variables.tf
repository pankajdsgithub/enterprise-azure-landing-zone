variable "definition_management_group_id" {
  description = "Management group ID where custom definitions/initiatives are stored (must be at or above every assignment scope). null = subscription scope of the provider."
  type        = string
  default     = null
}

variable "definitions" {
  type = map(object({
    display_name = string
    description  = string
    category     = optional(string, "General")
    mode         = optional(string, "All")
    policy_rule  = string # JSON string, usually file("...")
    parameters   = optional(string)
  }))
  default = {}
}

variable "initiatives" {
  type = map(object({
    display_name = string
    description  = string
    category     = optional(string, "General")
    definition_refs = map(object({
      definition_key   = optional(string) # key in var.definitions
      definition_id    = optional(string) # built-in or external definition ID
      parameter_values = optional(string)
    }))
  }))
  default = {}
}

variable "scope_type" {
  description = "Where assignments are made."
  type        = string

  validation {
    condition     = contains(["management_group", "subscription", "resource_group"], var.scope_type)
    error_message = "scope_type must be management_group, subscription or resource_group."
  }
}

variable "scope_id" {
  description = "Management group ID, subscription ID (/subscriptions/GUID) or resource group ID matching scope_type."
  type        = string
}

variable "assignments" {
  description = "Assignment name (max 24 chars at MG scope) => settings. Reference exactly one of initiative_key, definition_key, definition_id."
  type = map(object({
    display_name   = string
    initiative_key = optional(string)
    definition_key = optional(string)
    definition_id  = optional(string)
    enforce        = optional(bool, true)
    parameters     = optional(string)
    needs_identity = optional(bool, false) # true for DeployIfNotExists / Modify
    location       = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.assignments : length(k) <= 24])
    error_message = "Assignment names must be 24 characters or fewer (management group scope limit)."
  }

  validation {
    condition = alltrue([
      for k, v in var.assignments : length([for x in [v.initiative_key, v.definition_key, v.definition_id] : x if x != null]) == 1
    ])
    error_message = "Each assignment must set exactly one of initiative_key, definition_key or definition_id."
  }
}
