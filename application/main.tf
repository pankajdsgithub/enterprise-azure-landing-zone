locals {
  env    = var.environment
  suffix = "${local.env}-${var.location_short}-001"
  tags   = merge(var.tags, { environment = local.env })

  # Subnet plan derived from the spoke CIDR (/22): web /26, app /26, private endpoints /27
  subnets = {
    "snet-web" = { address_prefixes = [cidrsubnet(var.spoke_address_space, 4, 0)], default_outbound_access_enabled = false }
    "snet-app" = { address_prefixes = [cidrsubnet(var.spoke_address_space, 4, 1)], default_outbound_access_enabled = false }
    "snet-pe"  = { address_prefixes = [cidrsubnet(var.spoke_address_space, 5, 6)] }
  }
  web_cidr = local.subnets["snet-web"].address_prefixes[0]
  app_cidr = local.subnets["snet-app"].address_prefixes[0]
  pe_cidr  = local.subnets["snet-pe"].address_prefixes[0]

  use_firewall = var.firewall_private_ip != null

  dns_zone = {
    vault = "privatelink.vaultcore.azure.net"
    blob  = "privatelink.blob.core.windows.net"
    sql   = "privatelink.database.windows.net"
  }
}

module "rg_network" {
  source             = "../modules/resource-group"
  name               = "rg-network-${var.app_name}-${local.suffix}"
  location           = var.location
  tags               = local.tags
  enable_delete_lock = var.enable_delete_lock
}

module "rg_app" {
  source             = "../modules/resource-group"
  name               = "rg-${var.app_name}-${local.suffix}"
  location           = var.location
  tags               = local.tags
  enable_delete_lock = var.enable_delete_lock
}
