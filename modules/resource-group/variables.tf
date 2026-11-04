variable "name" {
  description = "Resource group name, e.g. rg-hub-connectivity-prd-cin-001."
  type        = string

  validation {
    condition     = can(regex("^rg-[a-z0-9-]{3,88}$", var.name))
    error_message = "Name must start with 'rg-' and contain only lowercase letters, digits and hyphens."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group."
  type        = map(string)
  default     = {}
}

variable "enable_delete_lock" {
  description = "Create a CanNotDelete lock on the resource group."
  type        = bool
  default     = false
}
