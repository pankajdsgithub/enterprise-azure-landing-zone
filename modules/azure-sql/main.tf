resource "azurerm_mssql_server" "this" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  version             = "12.0"
  minimum_tls_version = "1.2"

  # No SQL admin password anywhere: Entra ID authentication only.
  azuread_administrator {
    login_username              = var.entra_admin_login
    object_id                   = var.entra_admin_object_id
    azuread_authentication_only = true
  }

  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "this" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.this.id
  sku_name       = var.sku_name
  max_size_gb    = var.max_size_gb
  zone_redundant = var.zone_redundant
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  tags           = var.tags

  short_term_retention_policy {
    retention_days = var.pitr_retention_days
  }
}

resource "azurerm_monitor_diagnostic_setting" "db" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "diag-to-law"
  target_resource_id         = azurerm_mssql_database.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  enabled_metric {
    category = "Basic"
  }
}
