/*
 * Compute Module
 * This module creates either frontend compute resources with:
 * - VM Scale Set for application hosting
 * - Managed identity for secure authentication
 */

locals {
  ip_configuartion_name = "${var.web_vm_name}-ipconf"
}

# Network Interface Card Configuration
resource "azurerm_network_interface" "nic" {
  name                = "${var.web_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = local.ip_configuartion_name
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Attach NIC to Application Gateway Backend Pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = local.ip_configuartion_name
  backend_address_pool_id = var.appgw_backend_pool_id
}

# User-Assigned Managed Identity for the VM
resource "azurerm_user_assigned_identity" "identity" {
  name                = "${var.web_vm_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Grant AcrPull role to the User-Assigned Identity
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.acr_id != null ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

# Virtual Machine Configuration
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.web_vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.web_vm_metadata.size
  admin_username                  = var.web_vm_metadata.admin_username
  computer_name                   = var.web_vm_metadata.computer_name
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  # Attach User-Assigned Identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  custom_data = var.web_cloud_init

  # Authentication via Public SSH Key
  admin_ssh_key {
    username   = var.web_cloud_init
    public_key = var.web_ssh_public_key
  }

  # OS Disk Configuration
  os_disk {
    name                 = "${var.web_vm_name}-osdisk"
    caching              = var.web_os_disk.caching
    storage_account_type = var.web_os_disk.storage_account_type
  }

  # Source Image Reference
  source_image_reference {
    publisher = var.web_source_image.publisher
    offer     = var.web_source_image.offer
    sku       = var.web_source_image.sku
    version   = var.web_source_image.version
  }

  # Optional Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.web_boot_diagnostics.enabled ? [1] : []

    content {
      storage_account_uri = var.web_boot_diagnostics.storage_account_uri
    }
  }

  tags       = var.tags
  depends_on = [azurerm_role_assignment.acr_pull]
}
