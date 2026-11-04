module "rg_identity" {
  source   = "../../modules/resource-group"
  name     = "rg-identity-prd-${var.location_short}-001"
  location = var.location
  tags     = var.tags
}

# User-assigned identity usable by the CI/CD pipeline through workload identity federation:
# no client secret exists, so nothing can leak or expire.
module "pipeline_identity" {
  source                = "../../modules/managed-identity"
  name                  = "id-terraform-pipeline-prd-${var.location_short}-001"
  location              = var.location
  resource_group_name   = module.rg_identity.name
  role_assignments      = var.pipeline_role_assignments
  federated_credentials = var.pipeline_federated_credentials
  tags                  = var.tags
}

# Azure RBAC for Entra groups (the group objects themselves are Entra ID resources and are created
# by the identity team or via examples/entra-groups-optional which uses the AzureAD provider).
resource "azurerm_role_assignment" "groups" {
  for_each             = var.group_role_assignments
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.group_object_id
  principal_type       = "Group"
}
