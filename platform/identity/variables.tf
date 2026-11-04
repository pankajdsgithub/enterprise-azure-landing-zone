variable "location" {
  type    = string
  default = "centralindia"
}

variable "location_short" {
  type    = string
  default = "cin"
}

variable "pipeline_federated_credentials" {
  description = <<-EOT
    Optional. Name => { issuer, subject } for an Azure DevOps service connection that uses
    "Workload identity federation (manual)" with THIS managed identity. Copy issuer and subject
    from the service connection page.
  EOT
  type = map(object({
    issuer  = string
    subject = string
  }))
  default = {}
}

variable "pipeline_role_assignments" {
  description = "Scopes and roles for the pipeline identity. Least privilege: Contributor on specific subscriptions/RGs, never Owner."
  type = map(object({
    scope = string
    role  = string
  }))
  default = {}
}

variable "group_role_assignments" {
  description = "RBAC matrix: key => { scope, role, group_object_id }. Group object IDs come from Entra ID (see docs)."
  type = map(object({
    scope           = string
    role            = string
    group_object_id = string
  }))
  default = {}
}

variable "tags" {
  type = map(string)
  default = {
    environment = "platform"
    workload    = "identity"
    owner       = "identity-team"
    costcenter  = "it-platform"
    managedby   = "terraform"
  }
}
