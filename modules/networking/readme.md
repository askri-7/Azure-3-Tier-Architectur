# Network Module

## Purpose

The Network module creates and manages the **core private network infrastructure** for the Azure application.

Its responsibility is to define how the different application layers communicate while keeping private resources isolated from the public internet.

## What We Created

The module is responsible for:

* **Virtual Network (VNet)** — provides the private IP address space for the application.
* **Subnets** — separate the infrastructure into logical security zones.
* **Network Security Groups (NSGs)** — control which traffic is allowed between and into the subnets.
* **NAT Gateway** — provides controlled outbound internet access for private resources such as the backend without giving them a public IP.
* **Network-level configuration** — handles the relationships between these components.

## Our Network Structure

```text
VNet
│
├── Application Gateway Subnet
│   └── Application Gateway
│
├── Web Subnet
│   └── Frontend VM
│
├── App Subnet
│   └── Backend VM
│       └── NAT Gateway → Internet
│
├── PostgreSQL Subnet
│   └── Azure PostgreSQL Flexible Server
│
├── Bastion Subnet
│   └── Azure Bastion
│
└── Private Endpoints Subnet
    └── Private Endpoints
```

The subnet separation creates clear boundaries between the different layers.

## Security Principle

The network follows a **private-by-default** approach.

The public internet should reach the application through the **Application Gateway**, rather than directly accessing backend or database resources.

```text
Internet
   │
   ▼
Application Gateway
   │
   ▼
Private Application / Backend
   │
   ▼
Private PostgreSQL
```

For outbound traffic, the backend can use the NAT Gateway:

```text
Backend VM
    │
    ▼
NAT Gateway
    │
    ▼
Internet
```

This means the backend does not need its own public IP just to communicate with external services.

## Why This Is a Module

The network is a separate infrastructure responsibility and is shared by the other components.

Other modules consume its outputs instead of directly managing networking resources.

For example:

```text
Network Module
      │
      ├── subnet IDs ──────► VM Module
      │
      ├── subnet IDs ──────► PostgreSQL Module
      │
      ├── VNet ID ─────────► DNS Module
      │
      └── Network IDs ─────► Application Gateway
```

This keeps the root Terraform configuration clean and makes the network reusable across environments.
