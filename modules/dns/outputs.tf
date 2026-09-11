output "zone_ids" {
  value       = { for k, z in azurerm_private_dns_zone.zone : k => z.id }
  description = "Map of zone key -> private DNS zone ID"
}

output "zone_names" {
  value = { for k, z in azurerm_private_dns_zone.zone : k => z.name }
}