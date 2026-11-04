locals {
  suffix = "${var.location_short}-001"
  fw_dns = var.enable_firewall && var.firewall_sku_tier != "Basic" # DNS proxy needs Standard+

  hub_subnets = merge(
    {
      "snet-shared" = { address_prefixes = ["10.0.1.0/25"] }
      "snet-mgmt"   = { address_prefixes = ["10.0.1.128/26"] }
      # GatewaySubnet is reserved for a future VPN/ExpressRoute gateway (no cost until a gateway exists).
      "GatewaySubnet" = { address_prefixes = ["10.0.0.192/27"] }
    },
    var.enable_firewall ? { "AzureFirewallSubnet" = { address_prefixes = ["10.0.0.0/26"] } } : {},
    var.enable_firewall && var.firewall_sku_tier == "Basic" ? { "AzureFirewallManagementSubnet" = { address_prefixes = ["10.0.0.64/26"] } } : {},
    var.enable_bastion ? { "AzureBastionSubnet" = { address_prefixes = ["10.0.0.128/26"] } } : {},
  )
}

module "rg_hub" {
  source   = "../../modules/resource-group"
  name     = "rg-hub-connectivity-prd-${local.suffix}"
  location = var.location
  tags     = var.tags
}

module "rg_dns" {
  source   = "../../modules/resource-group"
  name     = "rg-privatedns-connectivity-prd-${local.suffix}"
  location = var.location
  tags     = var.tags
}

module "nsg_shared" {
  source                     = "../../modules/nsg"
  name                       = "nsg-snet-shared-prd-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_hub.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags

  rules = {
    allow-https-from-spokes = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["443"]
      source_address_prefixes      = values(var.spoke_address_spaces)
      destination_address_prefixes = ["10.0.1.0/25"]
    }
    deny-internet-inbound = {
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["Internet"]
      destination_address_prefixes = ["*"]
    }
  }
}

module "nsg_mgmt" {
  source                     = "../../modules/nsg"
  name                       = "nsg-snet-mgmt-prd-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_hub.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags

  rules = {
    allow-ssh-from-bastion = {
      priority                     = 100
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      destination_port_ranges      = ["22", "3389"]
      source_address_prefixes      = ["10.0.0.128/26"]
      destination_address_prefixes = ["10.0.1.128/26"]
    }
    deny-internet-inbound = {
      priority                     = 4000
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      destination_port_ranges      = ["*"]
      source_address_prefixes      = ["Internet"]
      destination_address_prefixes = ["*"]
    }
  }
}

module "hub_vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-hub-prd-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_hub.name
  address_space       = var.hub_address_space
  subnets             = local.hub_subnets
  tags                = var.tags

  nsg_associations = {
    "snet-shared" = module.nsg_shared.id
    "snet-mgmt"   = module.nsg_mgmt.id
  }
}

# ---- OPTIONAL (cost) : Azure Firewall --------------------------------------
module "firewall" {
  count  = var.enable_firewall ? 1 : 0
  source = "../../modules/azure-firewall"

  name                       = "afw-hub-prd-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_hub.name
  sku_tier                   = var.firewall_sku_tier
  firewall_subnet_id         = module.hub_vnet.subnet_ids["AzureFirewallSubnet"]
  management_subnet_id       = try(module.hub_vnet.subnet_ids["AzureFirewallManagementSubnet"], null)
  dns_proxy_enabled          = local.fw_dns
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags

  network_rule_collections = {
    allow-spoke-to-spoke = {
      priority = 100
      action   = "Allow"
      rules = {
        spokes-any-dns = {
          protocols             = ["UDP", "TCP"]
          source_addresses      = values(var.spoke_address_spaces)
          destination_addresses = ["*"]
          destination_ports     = ["53"]
        }
        prod-isolated-from-nonprod = {
          protocols             = ["TCP"]
          source_addresses      = [var.spoke_address_spaces["dev"], var.spoke_address_spaces["qa"]]
          destination_addresses = [var.spoke_address_spaces["dev"], var.spoke_address_spaces["qa"]]
          destination_ports     = ["443"]
        }
      }
    }
  }

  application_rule_collections = {
    allow-outbound-web = {
      priority = 200
      action   = "Allow"
      rules = {
        allow-ms-updates = {
          source_addresses  = values(var.spoke_address_spaces)
          destination_fqdns = ["*.ubuntu.com", "*.microsoft.com", "*.azure.com"]
          protocols         = [{ type = "Https", port = 443 }, { type = "Http", port = 80 }]
        }
      }
    }
  }
}

# ---- OPTIONAL (cost) : Bastion ---------------------------------------------
resource "azurerm_public_ip" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "pip-bas-hub-prd-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bas-hub-prd-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_hub.name
  sku                 = "Basic"
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig-bas"
    subnet_id            = module.hub_vnet.subnet_ids["AzureBastionSubnet"]
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

# ---- Central Private DNS + hub link ----------------------------------------
module "private_dns" {
  source              = "../../modules/private-dns"
  resource_group_name = module.rg_dns.name
  zone_names          = var.private_dns_zones
  tags                = var.tags

  links = { for z in var.private_dns_zones : "link-hub-${replace(z, ".", "-")}" => {
    zone_name           = z
    resource_group_name = module.rg_dns.name
    virtual_network_id  = module.hub_vnet.id
  } }
}

# Network Watcher is auto-created per region by Azure (NetworkWatcherRG). We only reference it.
data "azurerm_network_watcher" "this" {
  count               = 0 # set to 1 once NetworkWatcherRG exists in your subscription
  name                = "NetworkWatcher_${var.location}"
  resource_group_name = "NetworkWatcherRG"
}
