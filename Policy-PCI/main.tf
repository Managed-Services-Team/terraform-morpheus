# Configure the Microsoft Azure Provider
provider "azurerm" {
features {}
#    use ENV VARS
    subscription_id = "************************************"
    client_id       = "************************************"
    client_secret   = "************************************"
    tenant_id       = "************************************"
	# whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
    version = "=2.5.0"
}

data "azurerm_subscription" "current" {}

resource "azurerm_policy_assignment" "example" {
  name                 = "PCI v3.2.1:2018"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/496eeda9-8f2f-4d5e-8dfd-204f0a92ed41"
}

