resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.zone_names)
  name                = each.key
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Links may target zones created here OR zones that already exist (by name + RG).
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.links

  name                  = each.key
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags

  depends_on = [azurerm_private_dns_zone.this]
}
