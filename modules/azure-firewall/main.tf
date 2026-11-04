locals {
  is_basic = var.sku_tier == "Basic"
}

resource "azurerm_public_ip" "fw" {
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

# Basic SKU requires a dedicated management subnet + public IP.
resource "azurerm_public_ip" "mgmt" {
  count               = local.is_basic ? 1 : 0
  name                = "pip-${var.name}-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                     = "fwp-${var.name}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.sku_tier
  threat_intelligence_mode = local.is_basic ? null : "Alert"
  tags                     = var.tags

  dynamic "dns" {
    for_each = local.is_basic ? [] : [1]
    content {
      proxy_enabled = var.dns_proxy_enabled
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id
  zones               = var.zones
  tags                = var.tags

  ip_configuration {
    name                 = "ipconfig-fw"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fw.id
  }

  dynamic "management_ip_configuration" {
    for_each = local.is_basic ? [1] : []
    content {
      name                 = "ipconfig-mgmt"
      subnet_id            = var.management_subnet_id
      public_ip_address_id = azurerm_public_ip.mgmt[0].id
    }
  }

  lifecycle {
    precondition {
      condition     = !local.is_basic || var.management_subnet_id != null
      error_message = "management_subnet_id (AzureFirewallManagementSubnet) is required for the Basic SKU."
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "rcg-platform"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 500

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections
    content {
      name     = network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.key
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collections
    content {
      name     = application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name              = rule.key
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "diag-to-law"
  target_resource_id         = azurerm_firewall.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
