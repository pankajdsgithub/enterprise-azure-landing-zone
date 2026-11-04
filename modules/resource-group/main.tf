resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

# Optional guard against accidental deletion (production profile).
resource "azurerm_management_lock" "this" {
  count      = var.enable_delete_lock ? 1 : 0
  name       = "lock-${var.name}"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform. Remove lock before terraform destroy."
}
