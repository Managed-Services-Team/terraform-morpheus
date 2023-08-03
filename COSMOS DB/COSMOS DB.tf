# Configure the Microsoft Azure Provider
provider "azurerm" {
   features {}
#    use ENV VARS
    //subscription_id = "8225c50c-5bbc-4c57-8005-e674465fab09"
    #client_id       = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #client_secret   = "xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #tenant_id       = "458e35b0-e533-490e-b4b6-ec0329aa4f28"
	subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
    # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
    version = ">2.5.0"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "example" {
  name                      = "${var.prefix}-cosmosdb-${random_integer.ri.result}"
  location                  = "${azurerm_resource_group.example.location}"
  resource_group_name       = "${azurerm_resource_group.example.name}"
  offer_type                = "Standard"
  kind                      = "GlobalDocumentDB"
  enable_automatic_failover = true
  //set ip_range_filter to allow azure services (0.0.0.0) and azure portal.
  ip_range_filter = "0.0.0.0"

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 400
    max_staleness_prefix    = 100001
  }

  geo_location {
    #prefix            = "${var.prefix}-customid"
    location          = "${azurerm_resource_group.example.location}"
    failover_priority = 1
  }

  geo_location {
    location          = "${var.failover_location}"
    failover_priority = 0
  }
}