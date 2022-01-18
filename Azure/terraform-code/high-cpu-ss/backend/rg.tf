resource "azurerm_resource_group" "rg"{
    name = join("-", [var.service, "storage", "rg", local.name-suffix])
    location = var.location
}