resource "azurerm_automation_account" "aa" {
  name                = join("", [var.service, "aa", local.name-suffix])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "Basic"

  tags = var.tags
}