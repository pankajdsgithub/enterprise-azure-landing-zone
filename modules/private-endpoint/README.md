# Module: private-endpoint

Private Endpoint with optional DNS zone group.

## Example usage

```hcl
module "example" {
  source = "../../modules/private-endpoint"

  name = "pep-kv"
  location = "centralindia"
  resource_group_name = module.rg.name
  subnet_id = module.vnet.subnet_ids["snet-pe"]
  target_resource_id = module.kv.id
  subresource_names = ["vault"]
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `subnet_id` | **yes** |
| `target_resource_id` | **yes** |
| `subresource_names` | **yes** |
| `private_dns_zone_ids` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `private_ip_address`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
