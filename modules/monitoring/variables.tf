variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "action_group_name" {
  type = string
}

variable "action_group_short_name" {
  description = "Max 12 characters."
  type        = string

  validation {
    condition     = length(var.action_group_short_name) <= 12
    error_message = "short_name must be 12 characters or fewer."
  }
}

variable "email_receivers" {
  description = "Receiver name => email address."
  type        = map(string)
  default     = {}
}

variable "create_application_insights" {
  type    = bool
  default = false
}

variable "application_insights_name" {
  type    = string
  default = null
}

variable "enable_activity_log" {
  description = "Send the current subscription's Activity Log to the workspace."
  type        = bool
  default     = false
}

variable "metric_alerts" {
  type = map(object({
    scopes           = list(string)
    description      = string
    severity         = number
    metric_namespace = string
    metric_name      = string
    aggregation      = string
    operator         = string
    threshold        = number
  }))
  default = {}
}

variable "create_vm_dcr" {
  type    = bool
  default = false
}

variable "dcr_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
