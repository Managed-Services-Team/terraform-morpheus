terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      # version = "~> 3.0"  # Use the latest stable version
    }
  }
}

provider "azurerm" {
  features {}

  # Use environment variables for credentials
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Generate a random string for unique resource group and VM names
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = true
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "terraform-rg-${random_string.unique.result}"
  location = "East US"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${random_string.unique.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${random_string.unique.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP Address
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-${random_string.unique.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${random_string.unique.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # RDP Rule (Port 3389)
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP Rule (Port 80)
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # ICMP Rule (Ping)
  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-${random_string.unique.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  timeouts {
    create = "30m"  # Increase timeout as needed
    delete = "30m"
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"  # Use variables for sensitive data
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  timeouts {
    create = "30m"  # Increase timeout as needed
    delete = "30m"
  }
}
