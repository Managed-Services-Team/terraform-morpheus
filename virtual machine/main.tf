# Configure the Microsoft Azure Provider
provider "azurerm" {
features {}
#    use ENV VARS
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
	# whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
}


resource "azurerm_resource_group" "thisrg" {
  name     = "${var.rg_name}"
  location = "${var.location}"
  tags     = "${var.default_tags}"
}


# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "edytf-vnet"
    address_space       = ["10.1.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.thisrg.name}"

    tags = "${merge(
        "${var.default_tags}",
        //map(
            //"keyword", "hcp",
            //"secretword", "hcpagain"
        //)
    )}"
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name = "${azurerm_resource_group.thisrg.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefixes       = ["10.1.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                = "myPublicIP"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.thisrg.name}"
    allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "edy-tf-nsg"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.thisrg.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags     = "${var.default_tags}"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                = "edy-tf-nic1"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.thisrg.name}"
    #network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags     = "${var.default_tags}"
}


# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "edy-tf-vm1"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.thisrg.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_B4ms"
    delete_os_disk_on_termination = "true"
    delete_data_disks_on_termination = "true"

    storage_os_disk {
        name              = "edy-tf-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "edyvm"
        admin_username = "edy"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/edy/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4PyxBxggPbTYLGwwo1PaYFTqYo3UDH0cQVzvs4M2QrHHA5Zw/ardvJeqhxXkvAffU8s4BMLmuUwWpnGbtM3aqbrJjV9o58NYtw8MrxyIl8XeYD2pUExjn9h/x2JjYR31IgleqVmiU+aoRT8Ey2D73HY3cKwAcuJYDaHRoKGPUoQTCTXV8HmbCJkVwPNRzWyY6hyqhlWe5dPpsUgGxoi3rg+CHE/Ufit9bkr0X1t9fDQUQ8Baz35fTNBSlNzWP3oGd8avgcFOdDXpYzjsybz8Y8bjgBzfKbNK/pIWbznTWcay8tWdq1OGuTBdlfkpEtan68tLejOh5wbEGEyC8wFgP"
        }
    }

    tags     = "${var.default_tags}"
}
