module "monitoring" {
  source                     = "../modules/monitoring"
  location                   = var.location
  resource_group_name        = module.rg_app.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.tags

  action_group_name       = "ag-${var.app_name}-${local.suffix}"
  action_group_short_name = substr("${var.app_name}${local.env}", 0, 12)
  email_receivers         = var.alert_email_receivers

  create_application_insights = true
  application_insights_name   = "appi-${var.app_name}-${local.suffix}"

  create_vm_dcr = var.enable_compute
  dcr_name      = "dcr-vm-${local.suffix}"

  metric_alerts = { for t, vm in module.vm : "alert-cpu-${t}-${local.suffix}" => {
    scopes           = [vm.id]
    description      = "Average CPU above 80% for 15 minutes on the ${t} tier"
    severity         = 2
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  } }
}

module "backup" {
  count  = var.enable_backup && var.enable_compute ? 1 : 0
  source = "../modules/backup"

  name                = "rsv-${var.app_name}-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_app.name
  storage_mode_type   = var.backup_storage_mode
  protected_vm_ids    = { for t, vm in module.vm : t => vm.id }
  tags                = local.tags
}
