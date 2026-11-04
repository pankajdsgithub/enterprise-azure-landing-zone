# Module: azure-policy

Custom definitions, initiatives and assignments at management group / subscription / resource group scope.

## Example usage

```hcl
module "example" {
  source = "../../modules/azure-policy"

  scope_type = "management_group"
  scope_id = module.mg.ids["mg-landingzones"]
  assignments = { "asg-example" = { display_name = "Example", definition_id = "<id>" } }
}
```

## Inputs

| Name | Required |
|------|----------|
| `definition_management_group_id` | no |
| `definitions` | no |
| `initiatives` | no |
| `scope_type` | **yes** |
| `scope_id` | **yes** |
| `assignments` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`definition_ids`, `initiative_ids`, `assignment_ids`, `assignment_principal_ids`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
