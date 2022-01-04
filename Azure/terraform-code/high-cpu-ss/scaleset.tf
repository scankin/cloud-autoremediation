resource "azurerm_windows_virtual_machine_scale_set" "win-vm-ss" {
  name                = join("-", [var.service, "ss", local.name-suffix])
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_password      = "passAdmin1!"
  admin_username      = "scottankin"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic"
    primary = true

    ip_configuration {
      name      = azurerm_subnet.snet.name
      primary   = true
      subnet_id = azurerm_subnet.snet.id
    }
  }

}