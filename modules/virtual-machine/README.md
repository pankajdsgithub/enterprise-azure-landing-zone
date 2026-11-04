# Module: virtual-machine

Linux VM: no public IP, SSH-key only, system-assigned identity, optional user-assigned identity, Azure Monitor Agent, LB attachment.

## Example usage

```hcl
module "example" {
  source = "../../modules/virtual-machine"

  name = "vm-web-dev"
  location = "centralindia"
  resource_group_name = module.rg.name
  subnet_id = module.vnet.subnet_ids["snet-web"]
  admin_ssh_public_key = var.admin_ssh_public_key
}
```

## Inputs

| Name | Required |
|------|----------|
| `name` | **yes** |
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `subnet_id` | **yes** |
| `size` | no |
| `zone` | no |
| `admin_username` | no |
| `admin_ssh_public_key` | **yes** |
| `os_disk_storage_type` | no |
| `encryption_at_host_enabled` | no |
| `user_assigned_identity_ids` | no |
| `attach_to_load_balancer` | no |
| `load_balancer_backend_pool_id` | no |
| `install_monitor_agent` | no |
| `associate_data_collection_rule` | no |
| `data_collection_rule_id` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`id`, `private_ip_address`, `system_assigned_principal_id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
