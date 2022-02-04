resource "azurerm_monitor_metric_alert" "scaleout-alert" {
  name                = join("-", ["highcpu", "vmss", "scale", "out"])
  resource_group_name = join("-", [var.service, "rg", var.location, var.environment])
  scopes              = [var.scale-set-id]

  description = "This will be triggered when The CPU is Greater than 80% for 5 minutes."
  frequency   = "PT5M"
  window_size = "PT15M"
  severity    = 2

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

resource "azurerm_monitor_metric_alert" "highcpu-alert" {
  name                = join("-", ["highcpu", "vmss", "alert"])
  resource_group_name = join("-", [var.service, "rg", var.location, var.environment])
  scopes              = [var.scale-set-id]

  description = "This will be triggered when The CPU is Greater than 80% for 5 minutes."
  frequency   = "PT1M"
  window_size = "PT5M"
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
# resource "azurerm_monitor_action_group" "scaleout-action-group" {
#   name                = join("-", ["highcpu", "alert"])
#   resource_group_name = azurerm_resource_group.rg.name
#   short_name          = "ag1"

#   automation_runbook_receiver {
#     name                  = join("-", ["action", "runbook"])
#     automation_account_id = azurerm_automation_account.aa.id
#     runbook_name          = azurerm_automation_runbook.highCPU-scaleout.name
#     is_global_runbook     = true
#     webhook_resource_id   = azurerm_automation_webhook.webhook.id
#     service_uri           = "http://test"
#   }
# }

#resource "azurerm_monitor_action_group" "high-cpu-alert-action-group" {
#  name                = join("-", ["highcpu", "scale", "out"])
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
#}