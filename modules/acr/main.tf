resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku_acr
  admin_enabled                 = false
  public_network_access_enabled = true
  tags                          = var.tags
}