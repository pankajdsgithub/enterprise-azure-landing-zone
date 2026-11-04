# Module: vnet-peering

ONE-direction peering. Call twice (hub->spoke, spoke->hub); the second call may use a provider alias for another subscription.

## Example usage

```hcl
module "example" {
  source = "../../modules/vnet-peering"

  name = "peer-dev-to-hub"
  resource_group_name = "rg-network"
  virtual_network_name = "vnet-spoke"
  remote_virtual_network_id = var.hub_vnet_id
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `resource_group_name` | **yes** |
| `virtual_network_name` | **yes** |
| `remote_virtual_network_id` | **yes** |
| `allow_forwarded_traffic` | no |
| `allow_gateway_transit` | no |
| `use_remote_gateways` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
