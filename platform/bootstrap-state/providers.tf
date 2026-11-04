# Authentication: `az login` locally (Azure CLI) and set ARM_SUBSCRIPTION_ID.
# No credentials are stored in code.
provider "azurerm" {
  features {}
  storage_use_azuread = true
}
