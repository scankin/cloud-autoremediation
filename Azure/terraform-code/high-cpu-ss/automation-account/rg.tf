resource "azurerm_resource_group" "rg"{
    name = join("-", [var.service, "aa", "rg", local.name-suffix])
    location = var.location
}