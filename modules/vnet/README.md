# Module: vnet

VNet plus subnets (for_each) and NSG / route table associations. A separate `subnet` module was deliberately NOT created: subnets cannot exist without a VNet, and splitting them adds indirection without reuse.

## Example usage

```hcl
module "example" {
  source = "../../modules/vnet"

  name = "vnet-spoke-dev-cin-001"
  location = "centralindia"
  resource_group_name = module.rg.name
  address_space = ["10.10.0.0/22"]
  subnets = { "snet-web" = { address_prefixes = ["10.10.0.0/26"] } }
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `address_space` | **yes** |
| `dns_servers` | no |
| `subnets` | **yes** |
| `nsg_associations` | no |
| `route_table_associations` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `name`, `subnet_ids`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
