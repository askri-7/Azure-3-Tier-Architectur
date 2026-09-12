

variable "resource_group_name" {
  type = string

}

variable "location" {
  type = string

}

variable "postgres_subnet_id" {
  type = string
}

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
variable "private_dns_zone_id" {
  type = string

}
variable "postgres_name" {
  type = string
}
variable "tenant_id" {
  type        = string
  description = "The Azure Entra ID Tenant ID"
}

variable "entra_admin_object_id" {
  type        = string
  description = "Object ID of the Entra ID user/group serving as DB Admin"
}

variable "entra_admin_name" {
  type        = string
  default     = "postgres-admin"
  description = "Display name for the Entra ID Administrator"
}

variable "tags" {
  type = map(string)


}