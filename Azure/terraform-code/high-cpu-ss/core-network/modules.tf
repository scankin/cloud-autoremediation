module "aa" {
  source = "../automation-account"

  environment = var.environment
  location    = var.location
  service     = var.service

  scale-set-id = azurerm_windows_virtual_machine_scale_set.win-vm-ss.id

  tags = var.tags
}

module "monitor" {
  source = "../azure-monitor"

  environment = var.environment
  location    = var.location
  service     = var.service

  scale-set-id = azurerm_windows_virtual_machine_scale_set.win-vm-ss.id


  tags = var.tags
}

module "asp" {
  source = "../app-service-plan"

  environment = var.environment
  location    = var.location
  service     = var.service

  tags = var.tags
}