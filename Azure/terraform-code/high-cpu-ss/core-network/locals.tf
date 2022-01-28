locals {
  location-codes = {
    uksouth = "uks"
    ukwest  = "ukw"
  }

  name-suffix = (join("-", [local.location-codes[var.location], var.environment]))

  tags = {
    terraform = "true",
    time = formatdate("YYYY-MM-DD H:mm:ss", data.external.date.result["date"])
    environment = (var.environment == "dev" ? "1" : "5")
  }
}