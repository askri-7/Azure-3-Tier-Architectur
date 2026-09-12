output "identity_name" {
	value       = azurerm_user_assigned_identity.app.name
	description = "Name used by PostgreSQL Entra principal creation."
}

output "identity_principal_id" {
	value       = azurerm_user_assigned_identity.app.principal_id
	description = "Object ID of the application VM managed identity."
}
