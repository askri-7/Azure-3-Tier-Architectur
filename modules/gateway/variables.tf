variable "vnet_name" {
  type = string

}

variable "location" {
  type = string

}

variable "resource_group_name" {
  type = string

}

variable "app_gateway_subnet_id" {
  type = string

}
variable "domain_name_label" {
  type = string
}

variable "tags" {
  type = map(string)

}

variable "sku_gateway" {
  type = string
}