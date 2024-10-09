variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "terra2"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westus"
}

variable "failover_location" {
  description = "The Azure Region which should be used for the alternate location for this example."
  default = "westus3"
}

variable "subscription_id" {
    type = string
    sensitive = false
}

variable "tenant_id" {
    type = string
    sensitive = true
}

variable "client_id" {
    type = string
    sensitive = true
}

variable "client_secret" {
    type = string
    sensitive = true
}

variable "cosmo_name" {
    type    = string
    default = "example-cosmo-db"
}
