resource "azurerm_monitor_metric_alert" "alert" {
  name                = join("-", ["highcpu", "vmss", "alert"])
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_windows_virtual_machine_scale_set.win-vm-ss.id]

  description = "This will be triggered when The CPU is Greater than 80% for 5 minutes."
  frequency   = "PT5M"
  severity    = 3

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

##Action Group to run the Automation account

#resource "azurerm_monitor_action_group" "action-group" {
#  name                = join("-", ["highcpu", "action"])
#  resource_group_name = azurerm_resource_group.rg.name
#  short_name          = "ag1"
#
#  automation_runbook_receiver {
#    name                  = "action-runbook"
#    automation_account_id = azurerm_automation_account.aa.id
#    runbook_name          = azurerm_automation_runbook.highCPU.name
#    is_global_runbook     = false
#    webhook_resource_id   = azurerm_automation_webhook.webhook.id
#    service_uri           = ""
#  }
#}