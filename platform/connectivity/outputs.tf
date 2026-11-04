output "hub_vnet_id" {
  value = module.hub_vnet.id
}

output "hub_vnet_name" {
  value = module.hub_vnet.name
}

output "hub_resource_group_name" {
  value = module.rg_hub.name
}

output "firewall_private_ip" {
  description = "null when the firewall is not deployed."
  value       = try(module.firewall[0].private_ip_address, null)
}

output "private_dns_zone_ids" {
  value = module.private_dns.zone_ids
}

output "private_dns_resource_group_name" {
  value = module.rg_dns.name
}
