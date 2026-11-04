locals {
  suffix = "${var.location_short}-001"
}

module "rg_monitoring" {
  source   = "../../modules/resource-group"
  name     = "rg-monitoring-mgmt-prd-${local.suffix}"
  location = var.location
  tags     = var.tags
}

# Single central workspace. Other subscriptions send logs here via diagnostic settings
# (enforced by policy) because diagnostic settings can target a workspace in another subscription.
module "law" {
  source              = "../../modules/log-analytics"
  name                = "log-central-mgmt-prd-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_monitoring.name
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags
}

module "monitoring" {
  source                     = "../../modules/monitoring"
  location                   = var.location
  resource_group_name        = module.rg_monitoring.name
  log_analytics_workspace_id = module.law.id
  action_group_name          = "ag-platform-ops-mgmt-prd-${local.suffix}"
  action_group_short_name    = "platformops"
  email_receivers            = var.alert_email_receivers
  enable_activity_log        = var.enable_activity_log
  tags                       = var.tags
}

# Defender for Cloud: explicit opt-in per plan (cost control).
resource "azurerm_security_center_subscription_pricing" "this" {
  for_each      = toset(var.defender_plans)
  resource_type = each.key
  tier          = "Standard"
}

resource "azurerm_security_center_contact" "this" {
  count               = var.security_contact_email == null ? 0 : 1
  email               = var.security_contact_email
  alert_notifications = true
  alerts_to_admins    = true
}
