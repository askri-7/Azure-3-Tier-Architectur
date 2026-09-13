output "infra_user_client_id" {
  value = module.infra_ci_identity.client_id

}

output "app_client_id" {
  value = module.app_image_push_identity.client_id

}

output "app_runtime_identity_name" {
  value       = module.app_tier.identity_name
  description = "User assigned identity name used by the app VM for PostgreSQL Entra authentication."
}

output "secret_rotation_identity_client_id" {
  value       = module.secret_rotation_identity.client_id
  description = "Client ID used by the Key Vault rotation workflow."
}

output "login_server" {
  value = module.acr.login_server
}