# Default provider  = the APPLICATION (spoke) subscription for this environment.
# Alias connectivity = the Connectivity subscription (hub peering + private DNS links).
# Locally both default to ARM_SUBSCRIPTION_ID when connectivity_subscription_id is null (single-subscription lab).
provider "azurerm" {
  features {}
  storage_use_azuread = true
}

provider "azurerm" {
  alias = "connectivity"
  features {}
  storage_use_azuread = true
  subscription_id     = var.connectivity_subscription_id
}
