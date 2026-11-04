# Module: management-group

Creates a 3-level management group tree and associates subscriptions. Tenant-level permissions required (see docs/governance/prerequisites.md).

## Example usage

```hcl
module "example" {
  source = "../../modules/management-group"

  level1 = { "mg-contoso" = { display_name = "Contoso" } }
  level2 = { "mg-platform" = { display_name = "Platform", parent = "mg-contoso" } }
}
```

## Inputs

| Name | Required |
|------|----------|
| `root_parent_id` | no |
| `level1` | no |
| `level2` | no |
| `level3` | no |
| `subscription_associations` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`ids`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
