# Module: log-analytics

Central Log Analytics workspace with retention and daily-cap guard-rails.

## Example usage

```hcl
module "example" {
  source = "../../modules/log-analytics"

  name = "log-central"
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
| `retention_in_days` | no |
| `daily_quota_gb` | no |
| `internet_ingestion_enabled` | no |
| `internet_query_enabled` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `name`, `workspace_id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
