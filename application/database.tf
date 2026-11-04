module "sql" {
  count  = var.enable_database ? 1 : 0
  source = "../modules/azure-sql"

  server_name           = "sql-${var.app_name}-${local.env}-${var.unique_suffix}"
  database_name         = "sqldb-${var.app_name}-${local.env}"
  location              = var.location
  resource_group_name   = module.rg_app.name
  entra_admin_login     = var.sql_entra_admin_login
  entra_admin_object_id = var.sql_entra_admin_object_id

  sku_name                   = var.sql_sku_name
  zone_redundant             = var.sql_zone_redundant
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.tags

}

module "pe_sql" {
  count                = var.enable_database ? 1 : 0
  source               = "../modules/private-endpoint"
  name                 = "pep-sql-${var.app_name}-${local.suffix}"
  location             = var.location
  resource_group_name  = module.rg_network.name
  subnet_id            = module.spoke_vnet.subnet_ids["snet-pe"]
  target_resource_id   = module.sql[0].server_id
  subresource_names    = ["sqlServer"]
  private_dns_zone_ids = compact([lookup(var.private_dns_zone_ids, local.dns_zone.sql, null)])
  tags                 = local.tags
}
