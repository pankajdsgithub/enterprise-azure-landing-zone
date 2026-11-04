terraform {
  required_version = "~> 1.9"

  # Partial configuration: values come from -backend-config (see environments/*/backend.hcl.example).
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
  }
}
