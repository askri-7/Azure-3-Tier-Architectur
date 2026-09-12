


# existing infra pipeline identity (runs terraform plan/apply)
module "infra_ci_identity" {
  source              = "../../modules/workflow-identity"
  identity_name       = "${var.naming.project}-${var.naming.env}-infra-identity"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
  audience_name       = local.default_audience_name
  issuer_url          = local.github_issuer_url
  federated_subjects  = var.infra_federated_subjects   
  role_assignments = {

    deployment = {
      role_name = "Contributor"
      scope     = data.azurerm_resource_group.rg.id
    }

    terraform_state = {
      role_name = "Storage Blob Data Contributor"
      scope     = data.azurerm_storage_account.sta.id
    }
    keyvault_secrets_officer = {
      role_name = "Key Vault Secrets Officer"
      scope     = module.keyvault.key_vault_id
    }

  }
}

# new identity — app repo's pipeline, image push only
module "app_image_push_identity" {
  source              = "../../modules/workflow-identity"
  identity_name       = "${var.naming.project}-${var.naming.env}-app-identity"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
  audience_name       = local.default_audience_name
  issuer_url          = local.github_issuer_url
  federated_subjects  = var.app_federated_subjects
  role_assignments = {
    acr_push = {
      role_name = "AcrPush"
      scope     = module.acr.acr_id
    }
  }
}