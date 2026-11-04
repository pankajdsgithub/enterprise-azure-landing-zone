# Module: route-table

Route table with UDRs; BGP propagation disabled by default for spokes.

## Example usage

```hcl
module "example" {
  source = "../../modules/route-table"

  name = "rt-spoke"
  location = "centralindia"
  resource_group_name = module.rg.name
  routes = { default = { address_prefix = "0.0.0.0/0", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.0.0.4" } }
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `bgp_route_propagation_enabled` | no |
| `routes` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
