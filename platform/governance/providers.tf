# PREREQUISITE: the deploying identity needs Management Group Contributor +
# Resource Policy Contributor at the target scope (Tenant Root Group for first-time setup;
# see docs/governance/prerequisites.md for elevating access).
provider "azurerm" {
  features {}
  storage_use_azuread = true
}
