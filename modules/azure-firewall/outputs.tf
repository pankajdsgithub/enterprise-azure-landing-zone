output "id" {
  value = azurerm_firewall.this.id
}

output "private_ip_address" {
  description = "Next hop for UDRs and DNS server for spokes."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "policy_id" {
  value = azurerm_firewall_policy.this.id
}

output "public_ip_address" {
  value = azurerm_public_ip.fw.ip_address
}
