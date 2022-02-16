module "aa" {
  source = "../automation-account"

  environment = var.environment
  location    = var.location
  service     = var.service

  scale-set-id = azurerm_windows_virtual_machine_scale_set.win-vm-ss.id


  tags = var.tags
}