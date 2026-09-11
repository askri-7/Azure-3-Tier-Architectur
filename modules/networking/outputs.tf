output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
output "nat_public_ip" {
  value = azurerm_public_ip.natgw.ip_address
}
output "app_gateway_subnet_id" {
  value = azurerm_subnet.app_gateway.id
}

output "web_subnet_id" {
  value = azurerm_subnet.web.id
}
output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "postgres_subnet_id" {
  value = azurerm_subnet.postgres.id
}
output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

