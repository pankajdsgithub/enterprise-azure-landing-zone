output "spoke_vnet_id" {
  value = module.spoke_vnet.id
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "storage_account_name" {
  value = module.storage.name
}

output "sql_server_fqdn" {
  value = try(module.sql[0].server_fqdn, null)
}

output "vm_private_ips" {
  value = { for t, vm in module.vm : t => vm.private_ip_address }
}

output "application_insights_id" {
  value = module.monitoring.application_insights_id
}
