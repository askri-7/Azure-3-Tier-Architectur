dynamic_subnets = {

  # ============================================================
  # APPLICATION GATEWAY SUBNET
  # ============================================================

  app-gateway = {

    cidr_block = "10.0.1.0/24"

    security_rules = [

      {
        name                       = "Allow-HTTPS-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      },

      {
        name                       = "Allow-HTTP-Inbound"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }

    ]
  }


  # ============================================================
  # WEB TIER
  # ============================================================

  web = {

    cidr_block = "10.0.2.0/24"

    security_rules = [

      # Application Gateway → Web
      {
        name                       = "Allow-AppGateway-HTTP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "*"
      },

      # Bastion → Web VM SSH
      {
        name                       = "Allow-Bastion-SSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.5.0/26"
        destination_address_prefix = "*"
      }

    ]
  }


  # ============================================================
  # APP TIER
  # ============================================================

  app = {

    cidr_block = "10.0.3.0/24"

    security_rules = [

      # Web tier → App tier
      {
        name                       = "Allow-Web-To-App"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3000"
        source_address_prefix      = "10.0.2.0/24"
        destination_address_prefix = "*"
      },

      # Bastion → App VM SSH
      {
        name                       = "Allow-Bastion-SSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.5.0/26"
        destination_address_prefix = "*"
      },

      # App → PostgreSQL
      {
        name                       = "Allow-PostgreSQL"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix     = "*"
        destination_address_prefix = "10.0.4.0/24"
      }

    ]
  }


  # ============================================================
  # POSTGRESQL SUBNET
  # ============================================================

  postgres = {

    cidr_block = "10.0.4.0/24"

    delegation = {
      name    = "postgresql-delegation"
      service = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }

    security_rules = [

      # App tier → PostgreSQL
      {
        name                       = "Allow-App-PostgreSQL"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "10.0.3.0/24"
        destination_address_prefix = "*"
      }

    ]
  }


  # ============================================================
  # AZURE BASTION SUBNET
  # ============================================================

  AzureBastionSubnet = {

    cidr_block = "10.0.5.0/26"

    security_rules = [

      # Bastion requires a specific set of rules.
      # We will configure these properly when we build Bastion.
      
    ]
  }


  # ============================================================
  # PRIVATE ENDPOINT SUBNET
  # ============================================================

  private-endpoints = {

    cidr_block = "10.0.6.0/24"

    security_rules = []

  }

}