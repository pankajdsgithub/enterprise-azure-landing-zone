# Module: resource-group

Creates a resource group with optional CanNotDelete lock.

## Example usage

```hcl
module "example" {
  source = "../../modules/resource-group"

  name = "rg-app1-dev-cin-001"
  location = "centralindia"
  tags = { environment = "dev" }
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `tags` | no |
| `enable_delete_lock` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`name`, `id`, `location`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
