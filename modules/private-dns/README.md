# Module: private-dns

Creates Private DNS zones and/or VNet links to existing zones.

## Example usage

```hcl
module "example" {
  source = "../../modules/private-dns"

  resource_group_name = "rg-dns"
  zone_names = ["privatelink.vaultcore.azure.net"]
}
```

## Inputs

| Name | Required |
|------|----------|
| `resource_group_name` | no |
| `zone_names` | no |
| `links` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`zone_ids`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
