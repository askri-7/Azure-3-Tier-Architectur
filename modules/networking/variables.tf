
variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)

}

variable "resource_group_name" {
  type = string
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

variable "tags" {
  type = map(string)
}

