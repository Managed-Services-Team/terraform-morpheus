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
