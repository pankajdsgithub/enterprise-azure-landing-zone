# ---- Management group hierarchy (see docs/architecture/management-groups.md) ----
module "management_groups" {
  source = "../../modules/management-group"

  level1 = {
    (var.org_mg_name) = { display_name = "Contoso" }
  }

  level2 = {
    "mg-platform"       = { display_name = "Platform", parent = var.org_mg_name }
    "mg-landingzones"   = { display_name = "Landing Zones", parent = var.org_mg_name }
    "mg-sandbox"        = { display_name = "Sandbox", parent = var.org_mg_name }
    "mg-decommissioned" = { display_name = "Decommissioned", parent = var.org_mg_name }
  }

  level3 = {
    "mg-connectivity" = { display_name = "Connectivity", parent = "mg-platform" }
    "mg-management"   = { display_name = "Management", parent = "mg-platform" }
    "mg-identity"     = { display_name = "Identity", parent = "mg-platform" }
    "mg-lz-nonprod"   = { display_name = "Non-Production", parent = "mg-landingzones" }
    "mg-lz-prod"      = { display_name = "Production", parent = "mg-landingzones" }
  }

  subscription_associations = var.subscription_associations
}

# ---- Built-in definitions looked up by display name (data source concept) ----
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "require_tag_on_rg" {
  display_name = "Require a tag on resource groups"
}

locals {
  org_mg_id = module.management_groups.ids[var.org_mg_name]
  lz_mg_id  = module.management_groups.ids["mg-landingzones"]
}

# ---- Custom definitions + initiatives ----
module "policy_definitions" {
  source                         = "../../modules/azure-policy"
  definition_management_group_id = local.org_mg_id
  scope_type                     = "management_group"
  scope_id                       = local.org_mg_id

  definitions = {
    "deny-public-ip" = {
      display_name = "Deny public IP address creation"
      description  = "Application landing zones must use private connectivity; internet egress is via the hub firewall."
      category     = "Network"
      policy_rule  = file("${path.module}/policies/deny-public-ip.json")
      parameters   = file("${path.module}/policies/deny-public-ip.parameters.json")
    }
    "storage-secure-config" = {
      display_name = "Storage accounts must use HTTPS, TLS 1.2 and block public blob access"
      description  = "Deny storage accounts that allow HTTP, TLS below 1.2 or anonymous blob access."
      category     = "Storage"
      policy_rule  = file("${path.module}/policies/storage-secure-config.json")
      parameters   = file("${path.module}/policies/storage-secure-config.parameters.json")
    }
    "inherit-tag-from-rg" = {
      display_name = "Inherit a tag from the resource group if missing"
      description  = "Modify effect: copies the tag value from the RG onto resources. Needs a managed identity with Tag Contributor."
      category     = "Tags"
      policy_rule  = file("${path.module}/policies/require-tag-on-rg-inherit.json")
      parameters   = file("${path.module}/policies/require-tag-on-rg-inherit.parameters.json")
    }
    "audit-keyvault-diagnostics" = {
      display_name = "Audit Key Vault diagnostic settings to Log Analytics"
      description  = "AuditIfNotExists: reports vaults with no diagnostic setting sending to a workspace."
      category     = "Monitoring"
      policy_rule  = file("${path.module}/policies/audit-keyvault-diagnostics.json")
    }
  }

  initiatives = {
    "init-enterprise-baseline" = {
      display_name = "Enterprise security and governance baseline"
      description  = "Locations, secure storage, tag governance and diagnostics audit."
      category     = "Governance"
      definition_refs = {
        storage_secure = { definition_key = "storage-secure-config" }
        kv_diag        = { definition_key = "audit-keyvault-diagnostics" }
      }
    }
  }

  assignments = {
    "asg-baseline" = {
      display_name   = "Enterprise baseline"
      initiative_key = "init-enterprise-baseline"
      enforce        = var.policy_enforce
    }
  }
}

# ---- Assignments that use built-ins or need parameters (separate module call per scope) ----
module "policy_assignments_org" {
  source                         = "../../modules/azure-policy"
  definition_management_group_id = local.org_mg_id
  scope_type                     = "management_group"
  scope_id                       = local.org_mg_id

  assignments = merge(
    {
      "asg-allowed-locations" = {
        display_name  = "Allowed locations"
        definition_id = data.azurerm_policy_definition.allowed_locations.id
        enforce       = var.policy_enforce
        parameters    = jsonencode({ listOfAllowedLocations = { value = var.allowed_locations } })
      }
    },
    {
      for t in var.required_tags : "asg-reqtag-${substr(t, 0, 12)}" => {
        display_name  = "Require tag ${t} on resource groups"
        definition_id = data.azurerm_policy_definition.require_tag_on_rg.id
        enforce       = var.policy_enforce
        parameters    = jsonencode({ tagName = { value = t } })
      }
    }
  )
}

# Deny public IPs ONLY in landing zones. The Connectivity subscription (firewall/bastion/gateway)
# sits under mg-platform, so it is naturally excluded: scope drives exemption.
module "policy_assignments_lz" {
  source                         = "../../modules/azure-policy"
  definition_management_group_id = local.org_mg_id
  scope_type                     = "management_group"
  scope_id                       = local.lz_mg_id

  assignments = {
    "asg-deny-public-ip" = {
      display_name  = "Deny public IPs in landing zones"
      definition_id = module.policy_definitions.definition_ids["deny-public-ip"]
      enforce       = var.policy_enforce
    }
    "asg-inherit-env-tag" = {
      display_name   = "Inherit environment tag from RG (Modify)"
      definition_id  = module.policy_definitions.definition_ids["inherit-tag-from-rg"]
      enforce        = var.policy_enforce
      parameters     = jsonencode({ tagName = { value = "environment" } })
      needs_identity = true
      location       = var.policy_assignment_location
    }
  }
}

# Modify needs the role listed in roleDefinitionIds (Tag Contributor) for its identity to write tags (remediation tasks use the same identity).
resource "azurerm_role_assignment" "modify_identity" {
  scope                = local.lz_mg_id
  role_definition_name = "Tag Contributor"
  principal_id         = module.policy_assignments_lz.assignment_principal_ids["asg-inherit-env-tag"]
}
