# ---------------- NSGs (one per subnet, least privilege) ----------------
module "nsg_web" {
  source                     = "../modules/nsg"
  name                       = "nsg-snet-web-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_network.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.tags

  rules = {
    allow-https-in = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["443"]
      source_address_prefixes      = ["10.0.0.0/8"]
      destination_address_prefixes = [local.web_cidr]
    }
    allow-ssh-from-bastion = {
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["22"]
      source_address_prefixes      = [var.bastion_subnet_cidr]
      destination_address_prefixes = [local.web_cidr]
    }
    allow-azure-lb-probe = {
      priority                     = 120
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["AzureLoadBalancer"]
      destination_address_prefixes = ["*"]
    }
    deny-all-other-inbound = {
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["*"]
    }
  }
}

module "nsg_app" {
  source                     = "../modules/nsg"
  name                       = "nsg-snet-app-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_network.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.tags

  rules = {
    allow-app-port-from-web = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["8080"]
      source_address_prefixes      = [local.web_cidr]
      destination_address_prefixes = [local.app_cidr]
    }
    allow-ssh-from-bastion = {
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["22"]
      source_address_prefixes      = [var.bastion_subnet_cidr]
      destination_address_prefixes = [local.app_cidr]
    }
    deny-all-other-inbound = {
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["*"]
    }
  }
}

module "nsg_pe" {
  source                     = "../modules/nsg"
  name                       = "nsg-snet-pe-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_network.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.tags

  rules = {
    allow-data-from-app = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["443", "1433"]
      source_address_prefixes      = [local.app_cidr, local.web_cidr]
      destination_address_prefixes = [local.pe_cidr]
    }
    deny-all-other-inbound = {
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["*"]
      destination_address_prefixes = ["*"]
    }
  }
}

# ---------------- UDR: default route to hub firewall (only when a firewall exists) ----------------
# Spokes peer ONLY with the hub, so spoke-to-spoke has no system route; 0.0.0.0/0 sends it
# to the firewall, which applies policy and forwards (hub has system routes to every peered spoke).
module "route_table" {
  count  = local.use_firewall ? 1 : 0
  source = "../modules/route-table"

  name                          = "rt-spoke-${local.suffix}"
  location                      = var.location
  resource_group_name           = module.rg_network.name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  routes = {
    default-to-firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  }
}

# ---------------- Spoke VNet ----------------
module "spoke_vnet" {
  source              = "../modules/vnet"
  name                = "vnet-spoke-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_network.name
  address_space       = [var.spoke_address_space]
  dns_servers         = var.spoke_dns_servers
  subnets             = local.subnets
  tags                = local.tags

  nsg_associations = {
    "snet-web" = module.nsg_web.id
    "snet-app" = module.nsg_app.id
    "snet-pe"  = module.nsg_pe.id
  }

  # Keys are static, so the map is plan-safe; the route table only exists with a firewall.
  route_table_associations = local.use_firewall ? {
    "snet-web" = module.route_table[0].id
    "snet-app" = module.route_table[0].id
  } : {}
}

# ---------------- Peering (both directions; hub side uses the connectivity provider) ----------------
module "peer_spoke_to_hub" {
  source = "../modules/vnet-peering"

  name                      = "peer-${local.env}-to-hub"
  resource_group_name       = module.rg_network.name
  virtual_network_name      = module.spoke_vnet.name
  remote_virtual_network_id = var.hub_vnet_id
  allow_forwarded_traffic   = true
  use_remote_gateways       = var.hub_has_gateway
}

module "peer_hub_to_spoke" {
  source    = "../modules/vnet-peering"
  providers = { azurerm = azurerm.connectivity }

  name                      = "peer-hub-to-${local.env}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = module.spoke_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = var.hub_has_gateway
}

# ---------------- Private DNS links for this spoke ----------------
module "dns_links" {
  count     = var.link_private_dns_to_spoke && length(var.private_dns_zone_ids) > 0 ? 1 : 0
  source    = "../modules/private-dns"
  providers = { azurerm = azurerm.connectivity }

  tags = local.tags
  links = { for z, id in var.private_dns_zone_ids : "link-${local.env}-${replace(z, ".", "-")}" => {
    zone_name           = z
    resource_group_name = var.private_dns_resource_group_name
    virtual_network_id  = module.spoke_vnet.id
  } }
}
