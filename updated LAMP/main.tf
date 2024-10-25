provider "azurerm" {
  features {}

  # Use environment variables for credentials
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
# Generate random strings for unique names
resource "random_string" "random" {
  length  = 8
  special = false
}
resource "azurerm_resource_group" "lamp" {
  name     = "lamp-resources-${random_string.random.result}"
  location = "West Europe"
}
resource "azurerm_virtual_network" "lamp" {
  name                = "lamp-network-${random_string.random.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lamp.location
  resource_group_name = azurerm_resource_group.lamp.name
}
resource "azurerm_subnet" "lamp" {
  name                 = "internal-${random_string.random.result}"
  resource_group_name  = azurerm_resource_group.lamp.name
  virtual_network_name = azurerm_virtual_network.lamp.name
  address_prefixes     = ["10.0.2.0/24"]
}
# Public IP Address
resource "azurerm_public_ip" "lamp" {
  name                = "lamp-public-ip-${random_string.random.result}"
  location            = azurerm_resource_group.lamp.location
  resource_group_name = azurerm_resource_group.lamp.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Network Security Group (NSG) with SSH rule (port 22 open to the public)
resource "azurerm_network_security_group" "lamp" {
  name                = "lamp-nsg-${random_string.random.result}"
  location            = azurerm_resource_group.lamp.location
  resource_group_name = azurerm_resource_group.lamp.name
  security_rule {
    name                       = "allow_ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "lamp" {
  name                = "lamp-nic-${random_string.random.result}"
  location            = azurerm_resource_group.lamp.location
  resource_group_name = azurerm_resource_group.lamp.name
  ip_configuration {
    name                          = "internal-${random_string.random.result}"
    subnet_id                     = azurerm_subnet.lamp.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lamp.id
  }
}
# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.lamp.id
  network_security_group_id = azurerm_network_security_group.lamp.id
}
resource "azurerm_linux_virtual_machine" "lamp" {
  name                = "lamp-machine-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.lamp.name
  location            = azurerm_resource_group.lamp.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.lamp.id,
  ]
  admin_password = "P@ssw0rd123!" # Replace this with a strong password
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  # Cloud-init script to install LAMP stack
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    # Update and install Apache, MySQL, PHP
    sudo apt-get update -y
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    
    # Install MySQL
    sudo apt-get install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    # Install PHP and modules
    sudo apt-get install -y php libapache2-mod-php php-mysql
    # Restart Apache to apply changes
    sudo systemctl restart apache2
    # Print completion message
    echo "LAMP stack installation completed!"
  EOF
  )
}
