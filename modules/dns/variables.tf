variable "zones" {
  type        = map(string)
  description = "Map of private DNS zones to create, e.g. { key_vault = \"privatelink.vaultcore.azure.net\" }"
}

variable "vnet_id" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}