


locals {
  ip_configuartion_name =  "${var.vnet_name}-ipconf"
}

# Network Interface Card Configuration
resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "web-ip-configuration"
    subnet_id                     = var.web_subnet_id
    private_ip_address_allocation = var.web_ip_conf_allocation
  }

  tags = var.tags
}

# Attach NIC to Application Gateway Backend Pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "web-ip-configuration"
  backend_address_pool_id = var.appgw_backend_pool_id
}

# User-Assigned Managed Identity for the VM
resource "azurerm_user_assigned_identity" "identity" {
  name                = "${var.vm_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Grant AcrPull role to the User-Assigned Identity
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.web_acr_id != null ? 1 : 0
  scope                = var.web_acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

# Virtual Machine Configuration
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_metadata.size
  admin_username                  = var.vm_metadata.admin_username
  computer_name                   = var.vm_metadata.computer_name
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
    username   = var.vm_metadata.admin_username
    public_key = var.ssh_public_key
  }

  # OS Disk Configuration
  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  # Source Image Reference
  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }

  # Optional Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics.enabled ? [1] : []

    content {
      storage_account_uri = var.boot_diagnostics.storage_account_uri
    }
  }

  tags       = var.tags
  depends_on = [azurerm_role_assignment.acr_pull]
}
