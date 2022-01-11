#Commented out for now due to testing

#resource "azurerm_windows_virtual_machine_scale_set" "win-vm-ss" {
#  name                = join("-", [var.service, var.environment])
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#  instances           = 1
#  upgrade_mode        = "Automatic"
#  sku                 = "Standard_F2"
#  admin_password      = "passAdmin1!"
#  admin_username      = "scottankin"
#
#  source_image_reference {
#    publisher = "MicrosoftWindowsServer"
#    offer     = "WindowsServer"
#    sku       = "2016-Datacenter-Server-Core"
#    version   = "latest"
#  }
#
#  os_disk {
#    storage_account_type = "Standard_LRS"
#    caching              = "ReadWrite"
#  }
#
#  network_interface {
#    name    = "nic"
#    primary = true
#
#    ip_configuration {
#      name      = azurerm_subnet.snet.name
#      primary   = true
#      subnet_id = azurerm_subnet.snet.id
#    }
#  }
#
#  lifecycle {
#    ignore_changes = [instances]
#  }
#}

#resource "azurerm_monitor_autoscale_setting" "main" {
#  name                = "autoscale-configuration"
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#  target_resource_id  = azurerm_windows_virtual_machine_scale_set.win-vm-ss.id
#
#  profile {
#    name = "AutoScale"
#
#    capacity {
#      default = 1
#      minimum = 1
#      maximum = 5
#    }
#
#    rule {
#      metric_trigger {
#        metric_name        = "Percentage CPU"
#        metric_resource_id = azurerm_windows_virtual_machine_scale_set.win-vm-ss.id
#        time_grain         = "PT1M"
#        statistic          = "Average"
#        time_window        = "PT15M"
#        time_aggregation   = "Average"
#        operator           = "GreaterThan"
#        threshold          = 80
#      }
#
#      scale_action {
#        direction = "Increase"
#        type      = "ChangeCount"
#        value     = 1
#        cooldown  = "PT10M"
#      }
#    }
#
#    rule {
#      metric_trigger {
#        metric_name        = "Percentage CPU"
#        metric_resource_id = azurerm_windows_virtual_machine_scale_set.win-vm-ss.id
#        time_grain         = "PT1M"
#        statistic          = "Average"
#        time_window        = "PT15M"
#        time_aggregation   = "Average"
#        operator           = "LessThan"
#        threshold          = 30
#      }
#
#      scale_action {
#        direction = "Decrease"
#        type      = "ChangeCount"
#        value     = 1
#        cooldown  = "PT10M"
#      }
#    }
#  }
#}