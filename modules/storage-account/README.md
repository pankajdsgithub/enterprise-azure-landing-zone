# Module: storage-account

Hardened storage account (TLS1.2, no public blobs, Entra-only auth, deny-by-default firewall). Containers created via ARM so shared keys can stay disabled.

## Example usage

```hcl
module "example" {
  source = "../../modules/storage-account"

  name = "stapp1devcinx1y2z"
  location = "centralindia"
  resource_group_name = module.rg.name
  containers = ["appdata"]
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `replication_type` | no |
| `shared_access_key_enabled` | no |
| `public_network_access_enabled` | no |
| `infrastructure_encryption_enabled` | no |
| `versioning_enabled` | no |
| `soft_delete_days` | no |
| `allowed_ip_rules` | no |
| `containers` | no |
| `role_assignments` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `name`, `primary_blob_endpoint`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
