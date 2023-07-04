# Configure the Microsoft Azure Provider
provider "azurerm" {
#    use ENV VARS
    features {}
    subscription_id = "8225c50c-5bbc-4c57-8005-e674465fab09"
    //client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    //client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    tenant_id       = "458e35b0-e533-490e-b4b6-ec0329aa4f28"
	# whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
    version = ">2.0.0"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_virtual_desktop_workspace" "example" {
    name                     = "${var.prefix}workspace"
    resource_group_name      = "${azurerm_resource_group.example.name}"
    location                 = "${azurerm_resource_group.example.location}"
}

resource "azurerm_virtual_desktop_host_pool" "example" {
    resource_group_name      = "${azurerm_resource_group.example.name}"
    name                     = "${var.prefix}hostpool"
    location                 = "${azurerm_resource_group.example.location}"
    
    validate_environment     = false
    type                     = "Pooled"
    maximum_sessions_allowed = 16
    load_balancer_type       = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "example" {
    resource_group_name      = "${azurerm_resource_group.example.name}"
    host_pool_id             = azurerm_virtual_desktop_host_pool.example.id
    location                 = "${azurerm_resource_group.example.location}"
    type                     = "Desktop"
    name                     = "${var.prefix}dag"
    depends_on               = [azurerm_virtual_desktop_host_pool.example]
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "example" {
    application_group_id     = azurerm_virtual_desktop_application_group.example.id
    workspace_id             = azurerm_virtual_desktop_workspace.example.id
}