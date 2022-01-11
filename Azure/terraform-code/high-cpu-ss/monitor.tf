resource "azurerm_monitor_metric_alert" "alert" {
  name                = join("-", ["highcpu", "vmss", "alert"])
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_virtual_machine.vm.id]

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

  #action {
  #  action_group_id = azurerm_monitor_action_group.action-group.id
  #}
}

##Action Group to run the Automation account
#resource "azurerm_monitor_action_group" "action-group" {
#  name                = join("-", ["highcpu", "action"])
#  resource_group_name = azurerm_resource_group.rg.name
#  short_name          = "ag1"
#
#  automation_runbook_receiver {
#    name                  = join("-", ["action", "runbook"])
#    automation_account_id = azurerm_automation_account.aa.id
#    runbook_name          = azurerm_automation_runbook.highCPU.name
#    is_global_runbook     = true
#    webhook_resource_id   = azurerm_automation_webhook.webhook.id
#    service_uri           = "http://test"
#  }
#
#  azure_function_reciever {
#    name = join("-", ["action", "func"])
#    function_app_resource_id = azurerm_function_app.function-app.id
#    function_name = "HttpTrigger"
#  }
#}