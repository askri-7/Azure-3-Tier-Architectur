output "postgres_dns_zone_id" {
  description = "Resource ID of the PostgreSQL Private DNS Zone"
  value       = azurerm_private_dns_zone.postgres.id
}

output "postgres_dns_zone_name" {
  description = "Name of the PostgreSQL Private DNS Zone"
  value       = azurerm_private_dns_zone.postgres.name
}