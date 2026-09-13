output "identity_name" {
	value       = azurerm_user_assigned_identity.app.name
	description = "Name used by PostgreSQL Entra principal creation."
}

output "identity_principal_id" {
	value       = azurerm_user_assigned_identity.app.principal_id
	description = "Object ID of the application VM managed identity."
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.app.id
}

output "private_ip_address" {
	value = azurerm_network_interface.nic.private_ip_address
}
