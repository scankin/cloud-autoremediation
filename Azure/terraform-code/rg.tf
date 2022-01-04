azurermresource "azurerm_resource_group" "rg" {
   name = join("-", [var.service, "rg", var.location, var.environment])
   location = "West US"
}