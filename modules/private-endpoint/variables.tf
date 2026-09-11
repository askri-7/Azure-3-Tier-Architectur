variable "private_endpoint_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to place the private endpoint in"
}

variable "target_resource_id" {
  type        = string
  description = "Resource ID of the service being exposed (Key Vault, ACR, App Configuration...)"
}

variable "subresource_name" {
  type        = string
  description = "Subresource name: vault | registry | configurationstore"
}

variable "dns_zone_ids" {
  type        = list(string)
  description = "Private DNS zone IDs for the zone group"
}

variable "tags" {
  type = map(string)
}