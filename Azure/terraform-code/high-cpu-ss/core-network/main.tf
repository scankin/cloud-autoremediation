terraform {
  required_version = "~>2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.69"
    }
  }
}

provider "azurerm" {
  features {}
}