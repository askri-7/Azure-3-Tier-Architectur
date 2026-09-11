output "postgres_dns_zone_id" {
  value = azurerm_private_dns_zone.postgres.id
}


output "dsn_zone_network_link" {
  value = azurerm_private_dns_zone_virtual_network_link.postgres.id
  }