locals {
  location-codes = {
      uksouth = "uks"
      ukwest = "ukw"
  }

  name-suffix = (join("-", [local.location-codes[var.location], var.environment]))
}