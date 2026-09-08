output "app_gateway_id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.main.id
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway."
  value       = azurerm_public_ip.appgw.ip_address
}

output "backend_address_pool_id" {
  description = "The ID of the backend address pool to attach web tier instances."
  value       = tolist(azurerm_application_gateway.main.backend_address_pool)[0].id
}