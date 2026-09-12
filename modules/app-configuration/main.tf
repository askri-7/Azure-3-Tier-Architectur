resource "azurerm_app_configuration" "appconfig" {
  name                = var.app_config_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                = var.sku
  local_auth_enabled = false

  public_network_access      = "Disabled"
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = 7

  tags = var.tags
}