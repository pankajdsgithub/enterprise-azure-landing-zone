# Module: key-vault

RBAC-authorized Key Vault, public access disabled by default, optional diagnostics and role assignments.

## Example usage

```hcl
module "example" {
  source = "../../modules/key-vault"

  name = "kv-app1-dev-x1y2z"
  location = "centralindia"
  resource_group_name = module.rg.name
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `sku_name` | no |
| `purge_protection_enabled` | no |
| `soft_delete_retention_days` | no |
| `public_network_access_enabled` | no |
| `allowed_ip_rules` | no |
| `role_assignments` | no |
| `log_analytics_workspace_id` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `name`, `vault_uri`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
