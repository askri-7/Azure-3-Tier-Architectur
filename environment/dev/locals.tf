locals {
  default_audience_name = "api://AzureADTokenExchange"
  github_issuer_url     = "https://token.actions.githubusercontent.com"

  vnet_name               = "${var.naming.project}-${var.naming.env}-vnet"
  web_vm_name             = "${var.naming.project}-${var.naming.env}-web-vm"
  app_vm_name             = "${var.naming.project}-${var.naming.env}-app-vm"
  api_health_request_path = "${var.domain_name_label}/api/health"
  key_vault_name          = "${var.naming.project}-${var.naming.env}-kv"
  acr_name                = "${var.naming.project}-${var.naming.env}-acr"
  postgres_name           = "${var.naming.project}-${var.naming.env}-pg"
  private_dns_zone_name   = "${local.postgres_name}.private.postgres.database.azure.com"


}