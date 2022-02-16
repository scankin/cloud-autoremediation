terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "tfstate-autoremediation"
    storage_account_name = "value"
    container_name = "value"
    key = "dev-asp.tfstate"
  }
}

provider "azurerm" {
  features {}
}