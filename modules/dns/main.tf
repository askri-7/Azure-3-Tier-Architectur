/*
this module responsible for 
- configuring private dns zone 
- private link in a vritual network
*/
resource "azurerm_private_dns_zone" "zone" {
  for_each            = var.zones
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each              = var.zones
  name                  = "${var.vnet_name}-${each.key}-dnslink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.zone[each.key].name
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

