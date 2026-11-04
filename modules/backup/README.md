# Module: backup

Recovery Services vault, V2 daily VM backup policy, VM protection.

## Example usage

```hcl
module "example" {
  source = "../../modules/backup"

  name = "rsv-app1"
  location = "centralindia"
  resource_group_name = module.rg.name
  protected_vm_ids = { web = module.vm.id }
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `storage_mode_type` | no |
| `public_network_access_enabled` | no |
| `backup_time` | no |
| `instant_restore_days` | no |
| `daily_retention_count` | no |
| `weekly_retention_count` | no |
| `protected_vm_ids` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`vault_id`, `vault_name`, `policy_id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
