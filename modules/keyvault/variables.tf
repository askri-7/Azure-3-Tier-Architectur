variable "key_vault_name" {
  type = string

}

variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}


variable "tenant_id" {
  type = string

}

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



variable "tags" {
  type = map(string)

}