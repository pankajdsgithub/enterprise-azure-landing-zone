# Module: managed-identity

User-assigned identity, RBAC role assignments, federated credentials (workload identity federation).

## Example usage

```hcl
module "example" {
  source = "../../modules/managed-identity"

  name = "id-app1"
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
| `role_assignments` | no |
| `federated_credentials` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `principal_id`, `client_id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
