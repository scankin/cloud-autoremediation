resource "azurerm_storage_account" "storage" {
  name                     = join("", [var.service, "store", local.location-codes[var.location], var.environment])
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}