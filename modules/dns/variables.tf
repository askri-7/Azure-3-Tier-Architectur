variable "vnet_name" {
  type        = string
  
}

variable "vnet_id" {
  type        = string
  
}

variable "resource_group_name" {
  type        = string
}
variable "private_dns_zone_name" {
  type = string
}
variable "tags" {
  type        = map(string)
}