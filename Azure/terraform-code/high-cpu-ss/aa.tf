resource "azurerm_automation_account" "aa" {
  name                = join("", [var.service, "aa", local.name-suffix])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "Basic"

  tags = var.tags
}

resource "azurerm_automation_runbook" "highCPU" {
  name = "HighCPU-Runbook"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  log_verbose = "true"
  log_progess = "true"
  description = "This runbook creates a log file of information surrounding the CPU usage."
  runbook_type = "PowerShell"

  
}