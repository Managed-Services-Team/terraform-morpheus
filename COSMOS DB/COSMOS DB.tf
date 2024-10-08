# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # Use environment variables for credentials
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  # Pin the provider version for consistency
  version = ">2.5.0"
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = var.location
}

# Random Integer Generator for Unique Naming
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "example" {
  name                      = "${var.prefix}-cosmosdb-${random_integer.ri.result}"
  location                  = azurerm_resource_group.example.location
  resource_group_name       = azurerm_resource_group.example.name
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"

  # Allow Azure services and Azure portal access
  ip_range_filter = ["0.0.0.0"]

  # Enable Cosmos DB capabilities
  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  # Consistency Policy Configuration
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 400
    max_staleness_prefix    = 100001
  }

  # Primary Geo Location
  geo_location {
    location          = azurerm_resource_group.example.location
    failover_priority = 1
  }

  # Secondary Geo Location
  geo_location {
    location          = var.failover_location
    failover_priority = 0
  }
}
