# ---------------- Identity ----------------
module "app_identity" {
  source              = "../modules/managed-identity"
  name                = "id-${var.app_name}-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_app.name
  tags                = local.tags

  role_assignments = {
    blob-data = { scope = module.storage.id, role = "Storage Blob Data Contributor" }
  }
}

# ---------------- Key Vault (RBAC, private only) ----------------
module "key_vault" {
  source              = "../modules/key-vault"
  name                = "kv-${var.app_name}-${local.env}-${var.unique_suffix}"
  location            = var.location
  resource_group_name = module.rg_app.name

  purge_protection_enabled      = var.key_vault_purge_protection
  public_network_access_enabled = false
  log_analytics_workspace_id    = var.log_analytics_workspace_id
  tags                          = local.tags

  # VM system-assigned identities read secrets (least privilege: Secrets User, not Officer).
  role_assignments = { for t, vm in module.vm : "vm-${t}" => {
    role         = "Key Vault Secrets User"
    principal_id = vm.system_assigned_principal_id
  } }
}

module "pe_key_vault" {
  source               = "../modules/private-endpoint"
  name                 = "pep-kv-${var.app_name}-${local.suffix}"
  location             = var.location
  resource_group_name  = module.rg_network.name
  subnet_id            = module.spoke_vnet.subnet_ids["snet-pe"]
  target_resource_id   = module.key_vault.id
  subresource_names    = ["vault"]
  private_dns_zone_ids = compact([lookup(var.private_dns_zone_ids, local.dns_zone.vault, null)])
  tags                 = local.tags
}

# ---------------- Storage (no public access, Entra auth only) ----------------
module "storage" {
  source              = "../modules/storage-account"
  name                = "st${var.app_name}${local.env}${var.location_short}${var.unique_suffix}"
  location            = var.location
  resource_group_name = module.rg_app.name

  replication_type              = var.storage_replication_type
  shared_access_key_enabled     = false
  public_network_access_enabled = false
  containers                    = ["appdata"]
  tags                          = local.tags
}

module "pe_blob" {
  source               = "../modules/private-endpoint"
  name                 = "pep-blob-${var.app_name}-${local.suffix}"
  location             = var.location
  resource_group_name  = module.rg_network.name
  subnet_id            = module.spoke_vnet.subnet_ids["snet-pe"]
  target_resource_id   = module.storage.id
  subresource_names    = ["blob"]
  private_dns_zone_ids = compact([lookup(var.private_dns_zone_ids, local.dns_zone.blob, null)])
  tags                 = local.tags
}
