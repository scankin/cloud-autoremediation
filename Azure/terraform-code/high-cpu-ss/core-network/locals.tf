locals {
  location-codes = {
    uksouth = "uks"
    ukwest  = "ukw"
  }

  name-suffix = (join("-", [local.location-codes[var.location], var.environment]))

  tags = {
    terraform = "true",
    time = timestamp()
    environment = (var.environment == "dev" ? "1" : "5")
  }
}