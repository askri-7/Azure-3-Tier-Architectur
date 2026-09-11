variable "app_config_name" {
  type        = string
  description = "Name of the Azure App Configuration store"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "sku" {
  type        = string
  default     = "standard"
  description = "SKU for App Configuration (standard is recommended for production)"
}


variable "purge_protection_enabled" {
  type    = bool
  default = false
}




variable "configuration_settings" {
  type = map(object({
    value = string
  }))
  default     = {}
  description = "Map of non-secret Key-Value pairs to populate at setup"
}

variable "key_vault_references" {
  type = map(object({
    secret_id = string
  }))
  default     = {}
  description = "Map of Key Vault Secret IDs to expose through App Configuration pointers"
}

variable "tags" {
  type = map(string)

}