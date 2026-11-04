resource "azurerm_recovery_services_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Standard"
  storage_mode_type             = var.storage_mode_type
  soft_delete_enabled           = true
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = "bkpol-vm-daily"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  policy_type         = "V2"
  timezone            = "UTC"

  instant_restore_retention_days = var.instant_restore_days

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.daily_retention_count
  }

  dynamic "retention_weekly" {
    for_each = var.weekly_retention_count > 0 ? [1] : []
    content {
      count    = var.weekly_retention_count
      weekdays = ["Sunday"]
    }
  }
}

resource "azurerm_backup_protected_vm" "this" {
  for_each            = var.protected_vm_ids
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = each.value
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}
