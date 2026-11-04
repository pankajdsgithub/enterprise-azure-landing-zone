output "log_analytics_workspace_id" {
  value = module.law.id
}

output "action_group_id" {
  value = module.monitoring.action_group_id
}
