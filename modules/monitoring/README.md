# Module: monitoring

Action group, workspace-based Application Insights, subscription Activity Log export, metric alerts, Linux VM data collection rule.

## Example usage

```hcl
module "example" {
  source = "../../modules/monitoring"

  location = "centralindia"
  resource_group_name = module.rg.name
  log_analytics_workspace_id = module.law.id
  action_group_name = "ag-ops"
  action_group_short_name = "ops"
}
```

## Inputs

| Name | Required |
|------|----------|
| `location` | **yes** |
| `resource_group_name` | **yes** |
| `log_analytics_workspace_id` | **yes** |
| `action_group_name` | **yes** |
| `action_group_short_name` | **yes** |
| `email_receivers` | no |
| `create_application_insights` | no |
| `application_insights_name` | no |
| `enable_activity_log` | no |
| `metric_alerts` | no |
| `create_vm_dcr` | no |
| `dcr_name` | no |
| `tags` | no |

See `variables.tf` for types, descriptions and validation rules.

## Outputs

`action_group_id`, `application_insights_connection_string`, `application_insights_id`, `vm_dcr_id`

## Requirements

Terraform `~> 1.9`, `hashicorp/azurerm ~> 4.14` (see `versions.tf`).
