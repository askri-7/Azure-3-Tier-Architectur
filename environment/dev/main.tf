data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


data "azurerm_storage_account" "sta" {
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
}



module "networking" {
  source               = "../../modules/networking"
  vnet_name            = local.vnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = var.location
  address_space        = var.address_space
  ddos_protection_plan = var.ddos_protection_plan

  ## define 6 subnet 
  app_cidr_block         = var.app_cidr_block
  web_cidr_block         = var.web_cidr_block
  app_gateway_cidr_block = var.app_gateway_cidr_block
  postgres_cidr_block    = var.postgres_cidr_block
  bastion_cidr_block     = var.bastion_cidr_block
  private_cidr_block     = var.private_cidr_block


  ## define each subnet security rules

  web_security_rules      = var.web_security_rules
  app_security_rules      = var.app_security_rules
  gateway_security_rules  = var.gateway_security_rules
  postgres_security_rules = var.postgres_security_rules
  bastion_security_rules  = var.bastion_security_rules
  tags                    = var.tags

}

module "gateway" {
  source                = "../../modules/gateway"
  vnet_name             = local.vnet_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  domain_name_label     = var.domain_name_label
  app_gateway_subnet_id = module.networking.app_gateway_subnet_id
  sku_gateway           = var.sku_gateway
  tags                  = var.tags
}

module "web_tier" {
  source                = "../../modules/web_tier"
  web_vm_name           = local.web_vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  web_subnet_id         = module.networking.web_subnet_id
  web_vm_metadata       = var.web_vm_metadata
  web_os_disk           = var.web_os_disk
  appgw_backend_pool_id = module.gateway.backend_address_pool_id
  acr_id                = module.acr.acr_id
  web_cloud_init        = base64encode(templatefile(var.web_cloud_init_path, {}))
  web_source_image      = var.web_source_image
  web_ssh_public_key    = var.web_ssh_public_key
  web_boot_diagnostics  = var.web_boot_diagnostics
  tags                  = var.tags

}
module "keyvault" {
  source                        = "../../modules/keyvault"
  key_vault_name                = local.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_kv                        = var.sku_kv
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags



}
module "app_tier" {
  source                  = "../../modules/app_tier"
  app_vm_name             = local.app_vm_name
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  vnet_name               = local.vnet_name
  app_cloud_init          = base64encode(templatefile(var.app_cloud_init_path, {}))
  app_vm_metadata         = var.app_vm_metadata
  app_subnet_id           = module.networking.app_subnet_id
  key_vault_id            = module.keyvault.key_vault_id
  app_boot_diagnostics    = var.app_boot_diagnostics
  app_os_disk             = var.app_os_disk
  app_source_image        = var.app_source_image
  app_ssh_public_key      = var.app_ssh_public_key
  acr_id                  = module.acr.acr_id
  api_health_request_path = local.api_health_request_path
  tags                    = var.tags

}
module "acr" {
  source              = "../../modules/acr"
  acr_name            = local.acr_name
  sku_acr             = var.sku_acr
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
}


module "database" {
  source              = "../../modules/database"
  postgres_name       = local.postgres_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  postgres_subnet_id  = module.networking.postgres_subnet_id

  admin_username = var.admin_username
  admin_password = var.admin_password

  postgres_version = var.postgres_version
  sku_postgres     = var.sku_postgres
  storage_mb       = var.storage_mb


  db_name = var.db_name

  private_dns_zone_id   = module.private_dns.zone_ids["postgres"]
  private_dns_zone_link = module.private_dns.link_ids["postgres"]

  tags = var.tags




}
module "private_dns" {
  source              = "../../modules/dns"
  zones               = local.private_dns_zones
  vnet_id             = module.networking.vnet_id
  vnet_name           = local.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
}

module "keyvault_pe" {
  source              = "../../modules/private-endpoint"
  private_endpoint_name                 = "${local.key_vault_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = module.networking.private_endpoints_subnet_id
  target_resource_id  = module.keyvault.key_vault_id
  subresource_name    = "vault"
  dns_zone_ids        = [module.private_dns.zone_ids["key_vault"]]
  tags                = var.tags
}

module "acr_pe" {
  source              = "../../modules/private-endpoint"
  private_endpoint_name = "${local.acr_name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = module.networking.private_endpoints_subnet_id
  target_resource_id  = module.acr.acr_id
  subresource_name    = "registry"
  dns_zone_ids        = [module.private_dns.zone_ids["acr"]]
  tags                = var.tags
}