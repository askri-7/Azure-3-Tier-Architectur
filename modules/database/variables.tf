

variable "resource_group_name" {
  type = string

}

variable "location" {
  type = string

}

variable "postgres_subnet_id" {
  type = string
}

variable "admin_username" {
  type = string


}

variable "admin_password" {
  type      = string
  sensitive = true

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

variable "private_dns_zone_link" {
  type = string
}
variable "tags" {
  type = map(string)


}