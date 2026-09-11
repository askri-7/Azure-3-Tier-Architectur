# Provision Azure App Configuration Store
resource "azurerm_app_configuration" "appconfig" {
  name                       = var.app_config_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku                        = var.app_config_sku
  local_auth_enabled         = false
  public_network_access      = Disabled
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = 7

  tags = var.tags
}

# Optional: Seed initial non-secret configuration settings
resource "azurerm_app_configuration_key" "settings" {
  for_each               = var.configuration_settings
  configuration_store_id = azurerm_app_configuration.appconfig.id
  key                    = each.key
  label                  = var.tags.env
  value                  = each.value.value
  type                   = "kv"

  tags = var.tags
}

# Seed Key Vault References (Pointers to Key Vault secrets)
resource "azurerm_app_configuration_key" "vault_references" {
  for_each               = var.key_vault_references
  configuration_store_id = azurerm_app_configuration.appconfig.id
  key                    = each.key
  label                  = var.tags.env
  type                   = "vault"
  vault_key_reference    = each.value.secret_id

  tags = var.tags
}