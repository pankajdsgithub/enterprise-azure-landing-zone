data "azurerm_client_config" "current" {}

module "rg" {
  source             = "../../modules/resource-group"
  name               = var.resource_group_name
  location           = var.location
  tags               = var.tags
  enable_delete_lock = var.enable_delete_lock
}

module "state_storage" {
  source              = "../../modules/storage-account"
  name                = var.storage_account_name
  location            = var.location
  resource_group_name = module.rg.name
  tags                = var.tags

  replication_type                  = "GRS" # state is precious: geo-redundant
  shared_access_key_enabled         = false # Entra ID auth only (use_azuread_auth = true in backend)
  public_network_access_enabled     = true  # firewall below still denies everything except allowed IPs
  infrastructure_encryption_enabled = true
  versioning_enabled                = true # recover previous state versions
  soft_delete_days                  = 30
  allowed_ip_rules                  = var.allowed_ip_rules
  containers                        = var.state_containers

  role_assignments = merge(
    { deployer = { role = "Storage Blob Data Contributor", principal_id = data.azurerm_client_config.current.object_id } },
    { for k, v in var.additional_state_contributor_object_ids : k => { role = "Storage Blob Data Contributor", principal_id = v } }
  )
}
