output "id" {
  value = azurerm_virtual_network.this.id
}

output "name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet name => ID."
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}
