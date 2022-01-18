resource "azurerm_app_service_plan" "asp" {
  name                = join("-", [var.service, "asp", local.name-suffix])
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function-app" {
  name                       = join("-", [var.service, "func", local.name-suffix])
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = data.azurerm_storage_account.storage.name
  storage_account_access_key = data.azurerm_storage_account.storage.primary_access_key
}