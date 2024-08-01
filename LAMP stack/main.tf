# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
    #    use ENV VARS
        subscription_id = "${var.subscription_id}"
        client_id       = "${var.client_id}"
        client_secret   = "${var.client_secret}"
        tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

locals {
  instance_count = 2
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
}


resource "random_string" "fqdn" {
 length  = 6
 special = false
 upper   = false
 number  = false
}


resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  domain_name_label   = random_string.fqdn.result
}

resource "azurerm_network_interface" "main" {
  count               = local.instance_count
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.prefix}avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}


resource "azurerm_network_security_group" "webserver" {
  name                = "tls_webserver"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "80"
    destination_address_prefixes = [ for addr_prefix in azurerm_subnet.internal.address_prefixes : addr_prefix ]
  }
}


resource "azurerm_lb" "example" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_probe" "example" {
  loadbalancer_id     = azurerm_lb.example.id
  name                = "health-probe"
  port                = 80
}

#####
###resource "azurerm_lb_rule" "example" {
#  resource_group_name            = azurerm_resource_group.main.name
#  loadbalancer_id                = azurerm_lb.example.id
#  name                           = "LBRule"
#  protocol                       = "Tcp"
#  frontend_port                  = 80
#  backend_port                   = 80
#  frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
#  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
#  probe_id = azurerm_lb_probe.example.id
#}
####
resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id     = azurerm_lb.example.id
  name                = "BackEndAddressPool"
}


resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                   = local.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
  ip_configuration_name   = "primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
  probe_id = azurerm_lb_probe.example.id
}


data "template_file" "linux-vm-cloud-init" {
  template = file("azure-user-data.sh")
}


resource "azurerm_linux_virtual_machine" "main" {
  count                           = local.instance_count
  name                            = "${var.prefix}-vm${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  availability_set_id             = azurerm_availability_set.avset.id
  disable_password_authentication = false
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
