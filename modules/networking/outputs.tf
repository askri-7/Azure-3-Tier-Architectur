output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}



output "nat_public_ip" {
  value = azurerm_public_ip.natgw.ip_address
}


output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}

