/*
 * Network Module
 * This module responsible for creating and configuring  all networking components:
 * - Virtual Network with subnets
 * - Network Security Groups
 * - Bastion Host
 * - NAt gateway
 */


#  a vnet with ddos var plan

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.virtual_network_location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space # private ip adress range

  # configure ddos protection
    dynamic "ddos_protection_plan" {
        for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []
        content {
          enable = ddos_protection_plan.value.enable
          id     = ddos_protection_plan.value.id
        }
    }

  tags = var.tags
}
#subnet
resource "azurerm_subnet" "app_gateway" {
  name                 = "${var.vnet_name}-appgateway"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_gateway_cidr_block]
}

resource "azurerm_subnet" "web" {
  name                 = "${var.vnet_name}-web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.web_cidr_block]
}

resource "azurerm_subnet" "app" {
  name                 = "${var.vnet_name}-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_cidr_block]
}

resource "azurerm_subnet" "postgres" {
  name                 = "${var.vnet_name}-postgres"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.postgres_cidr_block]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_cidr_block]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_cidr_block]
}

#nsg  
resource "azurerm_network_security_group" "web" {

  name                =  "${var.vnet_name}-web-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name
  #skip CKV_AZURE_160 allow http on 80 to redirect later
 
  dynamic "security_rule" { # security_rule is the itterator
    for_each = var.web_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id

}

resource "azurerm_network_security_group" "app" {

  name                =  "${var.vnet_name}-app-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name
  #skip CKV_AZURE_160 allow http on 80 to redirect later
 
  dynamic "security_rule" { # security_rule is the itterator
    for_each = var.app_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id

}



resource "azurerm_network_security_group" "gateway" {

  name                =  "${var.vnet_name}-gateway-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name
  #skip CKV_AZURE_160 allow http on 80 to redirect later
 
  dynamic "security_rule" { # security_rule is the itterator
    for_each = var.gateway_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "gateway" {
  subnet_id                 = azurerm_subnet.app_gateway.id
  network_security_group_id = azurerm_network_security_group.gateway.id

}

resource "azurerm_network_security_group" "postgres" {

  name                =  "${var.vnet_name}-postgres-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name
  #skip CKV_AZURE_160 allow http on 80 to redirect later
 
  dynamic "security_rule" { # security_rule is the itterator
    for_each = var.postgres_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "postgres" {
  subnet_id                 = azurerm_subnet.postgres.id
  network_security_group_id = azurerm_network_security_group.postgres.id

}


resource "azurerm_network_security_group" "bastion" {

  name                =  "${var.vnet_name}-bastion-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name
  #skip CKV_AZURE_160 allow http on 80 to redirect later
 
  dynamic "security_rule" { # security_rule is the itterator
    for_each = var.bastion_security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id

}
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "${var.vnet_name}-private-endpoints-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.private_endpoint_security_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# NAT Gateway Provides outbound internet connectivity for private subnets
resource "azurerm_nat_gateway" "main" {
  name                    = "${var.vnet_name}-natgw"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  tags                    = var.tags
}
# NAT Gateway Public IP for backend subnets
resource "azurerm_public_ip" "natgw" {
  name                = "${var.vnet_name}-natgw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Associate NAT Gateway with its Public IP
resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

# Associate NAT Gateway with private subnets
resource "azurerm_subnet_nat_gateway_association" "private" {
  subnet_id      = azurerm_subnet.app.id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

# Bastion Public IP
resource "azurerm_public_ip" "bastion" {
  name                = "${var.vnet_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}


# Bastion Host
resource "azurerm_bastion_host" "main" {
  name                = "${var.vnet_name}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration_bastion_host"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}


