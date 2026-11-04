# Module: azure-sql

Azure SQL logical server + database, Entra-ID-only authentication (no passwords), TLS 1.2, public access off.

## Example usage

```hcl
module "example" {
  source = "../../modules/azure-sql"

  server_name = "sql-app1-dev-x1y2z"
  database_name = "sqldb-app1-dev"
  location = "centralindia"
  resource_group_name = module.rg.name
  entra_admin_login = "grp-sql-admins"
  entra_admin_object_id = var.sql_admin_group_object_id
}
```

## Inputs

| Name | Required |
|------|----------|
| `server_name` | **yes** |
| `database_name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `entra_admin_login` | **yes** |
| `entra_admin_object_id` | **yes** |
| `sku_name` | no |
| `max_size_gb` | no |
| `zone_redundant` | no |
| `pitr_retention_days` | no |
| `public_network_access_enabled` | no |
| `log_analytics_workspace_id` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`server_id`, `server_fqdn`, `database_id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
