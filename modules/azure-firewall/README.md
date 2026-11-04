# Module: azure-firewall

Azure Firewall + policy + rule collection group. Basic tier supported (needs management subnet). COST WARNING: hourly billing.

## Example usage

```hcl
module "example" {
  source = "../../modules/azure-firewall"

  name = "afw-hub"
  location = "centralindia"
  resource_group_name = module.rg.name
  firewall_subnet_id = module.hub.subnet_ids["AzureFirewallSubnet"]
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `sku_tier` | no |
| `firewall_subnet_id` | **yes** |
| `management_subnet_id` | no |
| `zones` | no |
| `dns_proxy_enabled` | no |
| `network_rule_collections` | no |
| `application_rule_collections` | no |
| `log_analytics_workspace_id` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `private_ip_address`, `policy_id`, `public_ip_address`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
