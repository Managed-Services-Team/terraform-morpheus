variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "terra"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "westus"
}

variable "rg_name" {
    description = "Azure Resource Group name where most of the resources are in"
    default = "terraform"
}

variable "default_tags" {
    type = map
    default = {}
}
