# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
    
    # Use environment variables
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id

    # Pin the provider version
    version = ">2.5.0"
}

resource "azurerm_subscription_template_deployment" "example" {
    name             = var.asc_name
    location         = "eastus"
    template_content = <<TEMPLATE
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.1",
    "parameters": {},
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
    "outputs": {}
}
TEMPLATE

    // Note: For better readability, consider sourcing this from a file.
}
