# Module: nsg

NSG with rules supplied as a map, optional diagnostics.

## Example usage

```hcl
module "example" {
  source = "../../modules/nsg"

  name = "nsg-web"
  location = "centralindia"
  resource_group_name = module.rg.name
  rules = {}
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `rules` | no |
| `log_analytics_workspace_id` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `name`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
