resource "azurerm_resource_group" "rg" {
  name = join("-",[var.service, "asp","rg", local.name-suffix])
  location = var.location
}