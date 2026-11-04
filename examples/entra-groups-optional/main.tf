# TENANT-LEVEL, OPTIONAL. Requires Entra ID permission "Group.ReadWrite.All"
# (or Groups Administrator role). Keep separate from subscription deployments.
provider "azuread" {}

variable "groups" {
  description = "Group display name => description."
  type        = map(string)
  default = {
    "grp-azure-platform-admins"  = "Platform engineers (eligible for PIM activation)"
    "grp-azure-network-ops"      = "Network operators"
    "grp-azure-app-dev-contrib"  = "Developers - Dev subscription Contributor"
    "grp-azure-app-prod-readers" = "Production read-only access"
  }
}

resource "azuread_group" "this" {
  for_each         = var.groups
  display_name     = each.key
  description      = each.value
  security_enabled = true
}

output "group_object_ids" {
  value = { for k, v in azuread_group.this : k => v.object_id }
}
