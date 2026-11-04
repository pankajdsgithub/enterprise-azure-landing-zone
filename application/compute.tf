# Web tier and app tier, driven by one map (for_each) => no copy/paste per tier.
locals {
  tiers = var.enable_compute ? {
    web = { subnet = "snet-web", identity_ids = [] }
    app = { subnet = "snet-app", identity_ids = [module.app_identity.id] }
  } : {}
}

resource "azurerm_lb" "web" {
  count               = var.enable_compute && var.enable_load_balancer ? 1 : 0
  name                = "lbi-web-${local.suffix}"
  location            = var.location
  resource_group_name = module.rg_app.name
  sku                 = "Standard"
  tags                = local.tags

  frontend_ip_configuration {
    name                          = "fe-web"
    subnet_id                     = module.spoke_vnet.subnet_ids["snet-web"]
    private_ip_address_allocation = "Dynamic"
    zones                         = ["1", "2", "3"]
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  count           = length(azurerm_lb.web)
  name            = "bepool-web"
  loadbalancer_id = azurerm_lb.web[0].id
}

resource "azurerm_lb_probe" "web" {
  count           = length(azurerm_lb.web)
  name            = "probe-https"
  loadbalancer_id = azurerm_lb.web[0].id
  protocol        = "Tcp"
  port            = 443
}

resource "azurerm_lb_rule" "web" {
  count                          = length(azurerm_lb.web)
  name                           = "rule-https"
  loadbalancer_id                = azurerm_lb.web[0].id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "fe-web"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web[0].id]
  probe_id                       = azurerm_lb_probe.web[0].id
}

module "vm" {
  source   = "../modules/virtual-machine"
  for_each = local.tiers

  name                       = "vm-${each.key}-${local.suffix}"
  location                   = var.location
  resource_group_name        = module.rg_app.name
  subnet_id                  = module.spoke_vnet.subnet_ids[each.value.subnet]
  size                       = var.vm_size
  zone                       = lookup(var.vm_zones, each.key, null)
  admin_ssh_public_key       = var.admin_ssh_public_key
  user_assigned_identity_ids = each.value.identity_ids
  tags                       = merge(local.tags, { tier = each.key })

  install_monitor_agent          = true
  associate_data_collection_rule = true
  data_collection_rule_id        = module.monitoring.vm_dcr_id

  attach_to_load_balancer       = each.key == "web" && var.enable_load_balancer
  load_balancer_backend_pool_id = each.key == "web" && var.enable_load_balancer ? azurerm_lb_backend_address_pool.web[0].id : null
}
