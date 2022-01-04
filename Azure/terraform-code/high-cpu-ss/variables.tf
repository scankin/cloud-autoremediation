variable "environment" {
  type = string

  validation {
    condition = contains(
      [
        "dev",
        "stg",
        "prd"
    ], var.environment)

    error_message = "The environment must contain either 'dev', 'stg' or 'prd'."
  }

  description = <<DESC
  The environment which the resources will be deployed to, either development, staging or production.
  DESC

  default = null
}

variable "location" {
  type = string

  validation {
    condition = contains(
      [
        "uksouth",
        "ukwest"
      ], var.location
    )

    error_message = "The location must either be 'uksouth' and 'ukwest'."
  }

  description = <<DESC
  The reigion where the resources will be deployed, either UK South or UK West.
  DESC

  default = null
}

variable "service" {
  type = string

  validation {
    condition = (
      var.service == null ||
      (coalesce(var.service, 0) >= 1 && coalesce(var.service, 9) <= 8)
    )

    error_message = "The name of the service must be a length >= 1 and <= 8."
  }

  description = <<DESC
  The service which the resources will be deployed to.
  DESC

  default = null
}

variable "tags" {
  type = map(any)

  description = <<DESC
    The tags used to describe resources.
    DESC

  default = {
    terraform = "true"
  }
}