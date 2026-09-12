### general config ###

variable "location" {
  type = string
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure subscription ID. Defaults to ARM_SUBSCRIPTION_ID when omitted."
}

variable "storage_account_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "naming" {
  type = map(string)
}
variable "tags" {
  type = map(string)
}

## global github action ci cd identity ###



variable "app_federated_subjects" {
  type = map(string)
}

variable "infra_federated_subjects" {
  type = map(string)
}

variable "migration_federated_subjects" {
  type    = map(string)
  default = {}
}

variable "secret_rotation_federated_subjects" {
  type    = map(string)
  default = {}
}


variable "role_assignments" {
  type = map(object({
    role_name = string
    scope     = string
  }))
}

variable "identity_name" {
  type = string
}


### networking ####

variable "address_space" {
  type = list(string)

}



variable "ddos_protection_plan" {
  type = object({
    enable = bool
    id     = string
  })
  default     = null
  description = "ddos_plan"
}


variable "vnet_name" {
  type = string
}

variable "app_gateway_cidr_block" {
  type = string

}
variable "app_cidr_block" {
  type = string
}

variable "postgres_cidr_block" {
  type = string
}
variable "bastion_cidr_block" {
  type = string
}

variable "private_cidr_block" {
  type = string
}
variable "web_cidr_block" {
  type = string
}
variable "web_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
variable "app_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
variable "gateway_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
variable "bastion_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}


variable "postgres_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
variable "private_endpoint_security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}


### web tier ####

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

variable "web_cloud_init" {
  type        = string
  default     = null
  description = "Base64-encoded cloud-init data"
}

variable "web_cloud_init_path" {
  type = string
}

## app tier ####

variable "app_cloud_init_path" {
  type = string
}



variable "app_vm_metadata" {
  type = object({
    size           = string
    admin_username = string
    computer_name  = string
  })
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

### gateway ##
variable "domain_name_label" {
  type = string
}
variable "sku_gateway" {
  type = string
}
## keyvault ##

variable "sku_kv" {
  type = string
}

variable "purge_protection_enabled" {
  type    = bool
  default = false
}
variable "public_network_access_enabled" {
  type    = bool
  default = false
}
### acr   ###

variable "sku_acr" {
  type = string
}


### database ###


variable "postgres_version" {
  type = string

}

variable "sku_postgres" {
  type = string


}

variable "storage_mb" {
  type = number


}

variable "db_name" {
  type = string


}
variable "entra_admin_name" {
  type = string
}
