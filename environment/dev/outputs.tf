output "infra_user_client_id" {
  value       = module.infra_ci_identity.client_id
  
}

output "app_client_id" {
  value       = module.app_image_push_identity.client_id
  
}

output "login_server" {
  value = module.acr.login_server
}