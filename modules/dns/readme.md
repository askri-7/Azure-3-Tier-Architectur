# Why DNS and PostgreSQL Should Be Terraform Modules

## Overview

A good Terraform architecture separates infrastructure into small, reusable modules based on responsibility.

For an Azure application, two good candidates for dedicated modules are:

- **DNS / Private DNS** — responsible for name resolution and DNS zones.
- **PostgreSQL** — responsible for the database server and database-specific configuration.

This follows the principle:

> **One module = one clear infrastructure responsibility.**

The goal is not to create a module for every Terraform resource. The goal is to create modules where a group of resources forms a reusable, understandable infrastructure component.

---

## 1. Why Put DNS in a Module?

DNS is a distinct infrastructure responsibility.

For example, Azure Private DNS may involve:

- Private DNS zones
- Virtual network links
- DNS records
- Zone configuration
- Dependencies between DNS and networking

Instead of mixing these resources directly into the root Terraform configuration, they can be grouped into a dedicated module.

### Example structure

```text
modules/
├── networking/
├── dns/
├── postgres/
├── application-gateway/
└── vm/
```

The DNS module can have a clear interface:

```text
modules/dns/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

The root configuration then describes **what DNS infrastructure it wants**, rather than how every DNS resource is implemented.

### Example

```hcl
module "dns" {
  source = "../../modules/dns"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  zone_name           = var.private_dns_zone_name
  virtual_network_id  = module.network.vnet_id
}
```

The root module remains easy to understand:

```text
Root Infrastructure
│
├── Network
├── DNS
├── PostgreSQL
├── Application Gateway
└── Virtual Machines
```

---

## 2. DNS Has Its Own Lifecycle

DNS does not necessarily have the same lifecycle as application servers.

For example:

```text
Network
   │
   ├── Private DNS
   │
   ├── PostgreSQL
   │
   └── Application
```

A PostgreSQL server may be replaced while the DNS architecture remains unchanged.

Keeping DNS separate makes this relationship clearer and reduces accidental changes.

It also allows the same DNS module to be reused for different environments:

```text
Development
└── DNS module

Staging
└── DNS module

Production
└── DNS module
```

---

## 3. Why Put PostgreSQL in a Module?

PostgreSQL is also a distinct infrastructure responsibility.

An Azure PostgreSQL Flexible Server can involve:

- PostgreSQL Flexible Server
- Administrator configuration
- PostgreSQL version
- SKU / compute
- Storage
- Backup retention
- High availability
- Network integration
- Private DNS integration
- Database-specific configuration

These settings logically belong to the **database layer**.

A dedicated PostgreSQL module keeps database-specific implementation details out of the root configuration.

### Example structure

```text
modules/
├── network/
├── dns/
├── postgres/
├── application-gateway/
└── vm/
```

Example usage:

```hcl
module "postgres" {
  source = "../../modules/postgres"

  name                = "${var.project}-${var.environment}-postgres"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  subnet_id           = module.network.subnet_ids["database"]
  private_dns_zone_id = module.dns.private_dns_zone_id

  administrator_login    = var.db_user
  administrator_password = var.db_password
}
```

The root module describes the architecture while the PostgreSQL module handles the implementation.

---

## 4. Separation of Responsibilities

A clean Terraform architecture might look like this:

```text
                    Root Module
                        │
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
     Network           DNS           PostgreSQL
        │               │                │
        ▼               ▼                ▼
     VNet/Subnets    DNS Zones      DB Server
     NSGs            VNet Links     Storage
     Routing                        Backup
                                     HA
```

Each module has a focused responsibility.
