variable "resource_group_name" {
  type = string
}

variable "location" {
  type        = string
  description = "location of both nic + vm"
}

variable "web_subnet_id" {
  type = string
}

variable "web_vm_metadata" {
  type = object({
    size           = string
    admin_username = string
    computer_name  = string
  })
}

variable "web_os_disk" {
  type = object({
    caching              = string
    storage_account_type = string
  })
}

variable "appgw_backend_pool_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "app_vm_private_ip" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "web_source_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "source image configuration"
}

variable "web_ssh_public_key" {
  type = string
}

variable "web_boot_diagnostics" {
  type = object({
    enabled             = bool
    storage_account_uri = optional(string)
  })

  default = {
    enabled = false
  }
  description = "boot diagnostics configuration"
}

variable "web_vm_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
