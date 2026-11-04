output "vault_id" {
  value = azurerm_recovery_services_vault.this.id
}

output "vault_name" {
  value = azurerm_recovery_services_vault.this.name
}

output "policy_id" {
  value = azurerm_backup_policy_vm.daily.id
}
