data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "kv" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name                      = var.sku_kv
  enable_rbac_authorization     = true # Use Azure RBAC instead of legacy access policies
  soft_delete_retention_days    = 7
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

