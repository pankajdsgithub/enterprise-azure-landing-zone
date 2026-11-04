locals {
  mg_assignments   = { for k, v in var.assignments : k => v if var.scope_type == "management_group" }
  sub_assignments  = { for k, v in var.assignments : k => v if var.scope_type == "subscription" }
  rg_assignments   = { for k, v in var.assignments : k => v if var.scope_type == "resource_group" }
  definition_scope = var.definition_management_group_id
}

# 1) Custom policy definitions (rule JSON lives in platform/governance/policies/*.json)
resource "azurerm_policy_definition" "this" {
  for_each = var.definitions

  name                = each.key
  policy_type         = "Custom"
  mode                = each.value.mode
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = local.definition_scope
  metadata            = jsonencode({ category = each.value.category, version = "1.0.0" })
  policy_rule         = each.value.policy_rule
  parameters          = each.value.parameters
}

# 2) Initiatives (policy sets) combining custom and built-in definitions
resource "azurerm_policy_set_definition" "this" {
  for_each = var.initiatives

  name                = each.key
  policy_type         = "Custom"
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = local.definition_scope
  metadata            = jsonencode({ category = each.value.category })

  dynamic "policy_definition_reference" {
    for_each = each.value.definition_refs
    content {
      policy_definition_id = coalesce(
        try(azurerm_policy_definition.this[policy_definition_reference.value.definition_key].id, null),
        policy_definition_reference.value.definition_id
      )
      reference_id     = policy_definition_reference.key
      parameter_values = policy_definition_reference.value.parameter_values
    }
  }
}

# 3) Assignments: one resource type per scope level.
resource "azurerm_management_group_policy_assignment" "this" {
  for_each = local.mg_assignments

  name                 = each.key
  management_group_id  = var.scope_id
  policy_definition_id = coalesce(try(azurerm_policy_set_definition.this[each.value.initiative_key].id, null), try(azurerm_policy_definition.this[each.value.definition_key].id, null), each.value.definition_id)
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  parameters           = each.value.parameters
  location             = each.value.needs_identity ? each.value.location : null

  dynamic "identity" {
    for_each = each.value.needs_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = local.sub_assignments

  name                 = each.key
  subscription_id      = var.scope_id
  policy_definition_id = coalesce(try(azurerm_policy_set_definition.this[each.value.initiative_key].id, null), try(azurerm_policy_definition.this[each.value.definition_key].id, null), each.value.definition_id)
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  parameters           = each.value.parameters
  location             = each.value.needs_identity ? each.value.location : null

  dynamic "identity" {
    for_each = each.value.needs_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_resource_group_policy_assignment" "this" {
  for_each = local.rg_assignments

  name                 = each.key
  resource_group_id    = var.scope_id
  policy_definition_id = coalesce(try(azurerm_policy_set_definition.this[each.value.initiative_key].id, null), try(azurerm_policy_definition.this[each.value.definition_key].id, null), each.value.definition_id)
  display_name         = each.value.display_name
  enforce              = each.value.enforce
  parameters           = each.value.parameters
  location             = each.value.needs_identity ? each.value.location : null

  dynamic "identity" {
    for_each = each.value.needs_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}
