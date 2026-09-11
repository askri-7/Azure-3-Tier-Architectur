/*
this module responsible for 
- provisionning database
- database configuration
- database backup
*/


resource "azurerm_postgresql_flexible_server" "main" {
  name                   = var.postgres_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgres_version
  delegated_subnet_id    = var.postgres_subnet_id
  private_dns_zone_id    = var.private_dns_zone_id
  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  sku_name                      = var.sku_postgres
  storage_mb                    = var.storage_mb
  public_network_access_enabled = false
  
  tags                          = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}