output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}
output "virtual_machine_name" {
  value = azurerm_windows_virtual_machine.vm.name
}
output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}