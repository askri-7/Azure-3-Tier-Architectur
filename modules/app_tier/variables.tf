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
variable "vm_name" { 
    type = string
    }
variable "app_cloud_init" {
  type = string
}
variable "web_acr_id" {
  type = string
}
variable "vm_metadata" {
  type = object({
    size           = string
    admin_username = string
    computer_name  = string
  })
}

variable "api_health_request_path" {
  type = string
}
variable "ssh_public_key" { 
    type = string 
}
variable "os_disk" {
  type = object({
    
    caching              = string
    storage_account_type = string

  })
  
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

variable "app_acr_id" { 
    type = string
    default = null
}

variable "acr_name" { 
    type = string 
    }
variable "app_image_name" {
    type = string
    }
variable "image_tag" { 
    type = string
    default = "latest" 
    }

variable "postgres_fqdn" { type = string }
variable "postgres_db_name" { type = string }
variable "postgres_admin_user" { type = string }

variable "tags" { type = map(string), default = {} }