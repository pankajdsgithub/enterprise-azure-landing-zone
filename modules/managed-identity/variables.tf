variable "name" {
  description = "e.g. id-app-web-dev-cin-001"
  type        = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "role_assignments" {
  description = "Key => { scope, role }. Keep scopes as narrow as possible."
  type = map(object({
    scope = string
    role  = string
  }))
  default = {}
}

variable "federated_credentials" {
  description = "Name => { issuer, subject }. For Azure DevOps use the issuer/subject shown on the service connection."
  type = map(object({
    issuer  = string
    subject = string
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
