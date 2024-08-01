variable "rg_name" {
    description = "Azure Resource Group name where most of the resources are in"
    default = ""
}

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
    description = "Azure Location/Region where the resources are to be created"
    default = ""
}

variable "default_tags" {
    default = {}
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