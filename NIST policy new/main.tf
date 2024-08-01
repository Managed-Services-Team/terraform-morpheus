# Configure the Microsoft Azure Provider
provider "azurerm" {
features {}
#    use ENV VARS
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
	# whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
    version = "=2.5.0"
}

data "azurerm_subscription" "current" {}

resource "azurerm_policy_assignment" "example" {
  name                 = "NIST SP 800-53 R4"
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/cf25b9c1-bd23-4eb6-bd2c-f4f3ac644a5f"
}

