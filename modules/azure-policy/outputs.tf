output "definition_ids" {
  value = { for k, v in azurerm_policy_definition.this : k => v.id }
}

output "initiative_ids" {
  value = { for k, v in azurerm_policy_set_definition.this : k => v.id }
}

output "assignment_ids" {
  value = merge(
    { for k, v in azurerm_management_group_policy_assignment.this : k => v.id },
    { for k, v in azurerm_subscription_policy_assignment.this : k => v.id },
    { for k, v in azurerm_resource_group_policy_assignment.this : k => v.id },
  )
}

output "assignment_principal_ids" {
  description = "Managed identity principal IDs for DeployIfNotExists/Modify assignments (grant roles + remediate)."
  value = merge(
    { for k, v in azurerm_management_group_policy_assignment.this : k => try(v.identity[0].principal_id, null) },
    { for k, v in azurerm_subscription_policy_assignment.this : k => try(v.identity[0].principal_id, null) },
    { for k, v in azurerm_resource_group_policy_assignment.this : k => try(v.identity[0].principal_id, null) },
  )
}
