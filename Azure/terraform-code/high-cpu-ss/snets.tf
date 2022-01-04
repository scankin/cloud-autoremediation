# Subnet for Scale Set
resource "azurerm_subnet" "snet" {
  name                 = join("-", [var.service, "snet", local.name-suffix])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}