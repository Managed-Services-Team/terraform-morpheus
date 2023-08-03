# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
#    use ENV VARS
   #subscription_id = "8225c50c-5bbc-4c57-8005-e674465fab09"
   # client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   # client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   # tenant_id       = "458e35b0-e533-490e-b4b6-ec0329aa4f28"
	subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
    # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
    version = ">2.5.0"
}
resource "azurerm_subscription_template_deployment" "example" {
  name             = "example-deployment-10"
  location         = "eastus"
  template_content = <<TEMPLATE
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.1",
    "parameters": {
    },
    "variables": {
        "autoProvisionSetting": "On",
        "ascOwnerEmail": "cloud.support@connection.com",
        "ascOwnerContact": "18007932222",
        "highSeverityAlertNotification": "On",
        "subscriptionOwnerNotification": "On",
        "virtualMachineTier": "Standard"
      },
    "resources": [
        {
            "type": "Microsoft.Security/autoProvisioningSettings",
            "apiVersion": "2017-08-01-preview",
            "name": "default",
            "properties": {
                "autoProvision": "[variables('autoProvisionSetting')]"
            }
        },
        {
            "type": "Microsoft.Security/securityContacts",
            "apiVersion": "2017-08-01-preview",
            "name": "default1",
            "properties": {
                "email": "[variables('ascOwnerEmail')]",
                "phone": "[variables('ascOwnerContact')]",
                "alertNotifications": "[variables('highSeverityAlertNotification')]",
                "alertsToAdmins": "[variables('subscriptionOwnerNotification')]"
            }
        },
        {
            "type": "Microsoft.Security/pricings",
            "apiVersion": "2018-06-01",
            "name": "VirtualMachines",
            "properties": {
                "pricingTier": "[variables('virtualMachineTier')]"
            }
        }
    ],
    "outputs": {
    }
}
 TEMPLATE

  // NOTE: whilst we show an inline template here, we recommend
  // sourcing this from a file for readability/editor support
}
