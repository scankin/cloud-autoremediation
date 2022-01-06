resource "azurerm_automation_account" "aa" {
  name                = join("", [var.service, "aa", local.name-suffix])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "Basic"

  tags = var.tags
}

##Creates the runbook for creating logs
resource "azurerm_automation_runbook" "highCPU" {
  name                    = "HighCPU-Runbook"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This runbook creates a log file of information surrounding the CPU usage."
  runbook_type            = "PowerShell"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/scankin/cloud-autoremediation/main/Azure/powershell-scripts/highcpu.ps1?token=AVRCHJHXIBGAS2VRDCHH3ALB23DJS"
  }
}

##Creates the webhook
resource "azurerm_automation_webhook" "webhook" {
  name                    = "HighCPU-Webhook"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  expiry_time             = "2022-12-31T00:00:00Z"
  enabled                 = true
  runbook_name            = azurerm_automation_runbook.highCPU.name
}