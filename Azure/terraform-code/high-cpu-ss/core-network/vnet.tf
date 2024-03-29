# Virtual network to host the scale set
resource "azurerm_virtual_network" "vnet" {
  name                = join("-", [var.service, "vnet", local.name-suffix])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}