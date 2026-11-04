output "action_group_id" {
  value = azurerm_monitor_action_group.this.id
}

output "application_insights_connection_string" {
  value     = try(azurerm_application_insights.this[0].connection_string, null)
  sensitive = true
}

output "application_insights_id" {
  value = try(azurerm_application_insights.this[0].id, null)
}

output "vm_dcr_id" {
  value = try(azurerm_monitor_data_collection_rule.vm[0].id, null)
}
