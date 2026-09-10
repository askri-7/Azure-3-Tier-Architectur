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

variable "vm_metadata" {
  type = object({
    size           = string
    admin_username = string
    computer_name  = string
  })
}

variable "os_disk" {
  type = object({
    
    caching              = string
    storage_account_type = string

  })
  
}
variable "appgw_backend_pool_id" {
  type = string
}
variable "web_acr_id" {
  type = string
}


variable "source_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "source image configuration"
}


variable "ssh_public_key" {
  type = string
}

variable "boot_diagnostics" {
  type = object({
    enabled             = bool
    storage_account_uri = optional(string)
  })

  default = {
    enabled = false
  }
  description = "boot diagnostics configuration"
}

variable "vm_name" {
  type = string
}
variable "tags" {
  type = map(string)
}


variable "web_cloud_init" {
  type        = string
  default     = null
  description = "Base64-encoded cloud-init data"
}