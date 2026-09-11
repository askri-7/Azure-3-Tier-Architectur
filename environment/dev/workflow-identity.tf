resource "azurerm_user_assigned_identity" "msi" {
  location            = var.location
  name                = var.identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "role" {
  for_each             = var.role_assignments
  principal_id         = azurerm_user_assigned_identity.msi.principal_id
  role_definition_name = each.value.role_name
  scope                = each.value.scope
}

resource "azurerm_federated_identity_credential" "cred" {
  for_each  = var.federated_subjects
  resource_group_name = data.azurerm_resource_group.rg.name
  name      = each.key
  audience  = [var.audience_name]
  issuer    = var.issuer_url
  parent_id = azurerm_user_assigned_identity.msi.id
  subject   = each.value
}