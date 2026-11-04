output "zone_ids" {
  description = "Zone name => zone ID (zones created by this module)."
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}
