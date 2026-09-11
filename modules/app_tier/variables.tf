variable "vnet_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "app_subnet_id" {
  type = string
}
variable "app_vm_name" {
  type = string
}
variable "app_cloud_init" {
  type = string
}
variable "acr_id" {
  type = string
}
variable "app_vm_metadata" {
  type = object({
    size           = string
    admin_username = string
    computer_name  = string
  })
}

variable "api_health_request_path" {
  type = string
}
variable "app_ssh_public_key" {
  type = string
}
variable "app_os_disk" {
  type = object({

    caching              = string
    storage_account_type = string
  })
}

variable "app_source_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "source image configuration"
}
variable "app_boot_diagnostics" {
  type = object({
    enabled             = bool
    storage_account_uri = optional(string)
  })

  default = {
    enabled = false
  }
  description = "boot diagnostics configuration"
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
}