terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name = "tfstate-autoremediation"
    storage_account_name = "tfstateautoremediation"
    container_name = "tfstate"
    key = "dev-aa.tfstate"
  }
}

provider "azurerm" {
  features {}
}