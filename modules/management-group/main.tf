# Three explicit levels because Terraform cannot express a recursive tree.
# Level 1 hangs off root_parent_id (null => Tenant Root Group).
locals {
  root_parent_id = var.root_parent_id == null ? "/providers/Microsoft.Management/managementGroups/${data.azurerm_client_config.current.tenant_id}" : var.root_parent_id
}

data "azurerm_client_config" "current" {}

resource "azurerm_management_group" "level1" {
  for_each                   = var.level1
  name                       = each.key
  display_name               = each.value.display_name
  parent_management_group_id = local.root_parent_id
}

resource "azurerm_management_group" "level2" {
  for_each                   = var.level2
  name                       = each.key
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.level1[each.value.parent].id
}

resource "azurerm_management_group" "level3" {
  for_each                   = var.level3
  name                       = each.key
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.level2[each.value.parent].id
}

locals {
  all_ids = merge(
    { for k, v in azurerm_management_group.level1 : k => v.id },
    { for k, v in azurerm_management_group.level2 : k => v.id },
    { for k, v in azurerm_management_group.level3 : k => v.id },
  )
}

# Subscription placement. Key = management group name, value = subscription id (GUID).
resource "azurerm_management_group_subscription_association" "this" {
  for_each            = var.subscription_associations
  management_group_id = local.all_ids[each.value.management_group]
  subscription_id     = "/subscriptions/${each.value.subscription_id}"
}
