resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = var.postgres_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.postgres_version

  public_network_access_enabled = false
  delegated_subnet_id = var.postgres_subnet_id
  private_dns_zone_id = var.private_dns_zone_id

  sku_name                      = var.sku_postgres
  storage_mb                    = var.storage_mb

  tags = var.tags

  # Enable Entra ID (Active Directory) Authentication
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = var.tenant_id
  }
  lifecycle {
    ignore_changes = [
      zone,
      high_availability
    ]
  }
}

# Assign the Entra ID Admin
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "admin" {
  server_name         = azurerm_postgresql_flexible_server.postgres.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  object_id           = var.entra_admin_object_id
  principal_name      = var.entra_admin_name
  principal_type      = "User"
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}