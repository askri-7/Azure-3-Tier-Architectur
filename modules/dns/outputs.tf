output "zone_ids" {
  value       = { for k, z in azurerm_private_dns_zone.zone : k => z.id }
  description = "Map of zone key -> private DNS zone ID"
}

output "zone_names" {
  value = { for k, z in azurerm_private_dns_zone.zone : k => z.name }
}

output "link_ids" {
  value       = { for k, l in azurerm_private_dns_zone_virtual_network_link.link : k => l.id }
  description = "Map of zone key -> VNet link ID (use for depends_on)"
}