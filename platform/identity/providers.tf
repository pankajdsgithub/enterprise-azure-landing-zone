# Target subscription = Connectivity subscription. Set ARM_SUBSCRIPTION_ID (CLI) or let the
# pipeline service connection supply it.
provider "azurerm" {
  features {}
  storage_use_azuread = true
}
