locals {
  location-codes = {
    uksouth = "uks"
    ukwest  = "ukw"
  }

  name-suffix = (join("-", [local.location-codes[var.location], var.environment]))

  storage-acc-name = join("", [var.service, "store", var.location, var.environment])
  storage-acc-rg = join("-", [var.service, "storage", "rg", local.name-suffix])
  storage-acc-location = var.location
}