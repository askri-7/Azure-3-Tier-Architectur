/*
 * Compute Module
 * This module creates either frontend or backend compute resources with:
 * - VM for application hosting
 * -internal LB for backend
 * - Managed identity for secure authentication
 */


# 1. User-Assigned Identity for App VM
resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.vnet_name}-app-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# 2. ACR Pull Role Assignment
resource "azurerm_role_assignment" "acr_pull" {
  
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
# Grant Key Vault Secrets User permission to the App VM identity
resource "azurerm_role_assignment" "kv_secrets_user" {
  
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# 3. Internal Load Balancer (ILB)
resource "azurerm_lb" "ilb" {
  name                = "${var.vnet_name}-app-ilb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "app-ilb-frontend"
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "ilb" {
  name            = "app-backend-pool"
  loadbalancer_id = azurerm_lb.ilb.id
}

resource "azurerm_lb_probe" "ilb" {
  name            = "api-health-probe"
  loadbalancer_id = azurerm_lb.ilb.id
  protocol        = "Http"
  port            = 8080
  request_path    = var.api_health_request_path
}

resource "azurerm_lb_rule" "ilb" {
  name                           = "api-rule"
  loadbalancer_id                = azurerm_lb.ilb.id
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "app-ilb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ilb.id]
  probe_id                       = azurerm_lb_probe.ilb.id
}


locals {
  ip_configuration_name = "${var.app_vm_name}-internalconf"
}
# 4. App VM Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.app_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = local.ip_configuration_name
    subnet_id                     = var.app_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# 5. Connect NIC to ILB Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "ilb" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = local.ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb.id
}

# 6. Linux VM (App API + Containerized Redis)
resource "azurerm_linux_virtual_machine" "app" {
  name                            = var.app_vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.app_vm_metadata.size
  admin_username                  = var.app_vm_metadata.admin_username
  computer_name                   = var.app_vm_metadata.computer_name
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  admin_ssh_key {
    username   = var.app_vm_metadata.admin_username
    public_key = var.app_ssh_public_key
  }

  os_disk {
    name                 = "${var.app_vm_name}-osdisk"
    caching              = var.app_os_disk.caching
    storage_account_type = var.app_os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.app_source_image.publisher
    offer     = var.app_source_image.offer
    sku       = var.app_source_image.sku
    version   = var.app_source_image.version
  }

  custom_data = var.app_cloud_init

  tags       = var.tags
  depends_on = [azurerm_role_assignment.acr_pull]


  dynamic "boot_diagnostics" {
    for_each = var.app_boot_diagnostics.enabled ? [1] : []

    content {
      storage_account_uri = var.app_boot_diagnostics.storage_account_uri
    }
  }
}