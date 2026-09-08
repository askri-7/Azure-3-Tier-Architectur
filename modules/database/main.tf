resource "azurerm_postgresql_flexible_server" "main" {
  name                   = var.postgres_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgres_version
  delegated_subnet_id    = var.postgres_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  sku_name   = var.sku_name
  storage_mb = var.storage_mb
  public_network_access_enabled = false

  tags = var.tags
}