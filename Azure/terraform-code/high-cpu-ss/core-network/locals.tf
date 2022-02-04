locals {
  location-codes = {
    uksouth = "uks"
    ukwest  = "ukw"
  }

  name-suffix = (join("-", [local.location-codes[var.location], var.environment]))

  tags = {
    terraform   = "true",
    environment = (var.environment == "dev" ? "1" : "5")
  }
}