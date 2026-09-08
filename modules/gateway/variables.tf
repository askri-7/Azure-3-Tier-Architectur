variable "vnet_name" {
  type        = string
  description = "Virtual network name prefix"
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "app_gateway_subnet_id" {
  type        = string
  description = "Subnet ID from networking module (azurerm_subnet.app_gateway.id)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to gateway resources"
}