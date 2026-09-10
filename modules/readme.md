### Network module

Responsible for:

- VNet
- Subnets
- NSGs
- Network-level configuration

### DNS module

Responsible for:

- Private DNS zones
- VNet links
- DNS records

### PostgreSQL module

Responsible for:

- PostgreSQL Flexible Server
- Database configuration
- Database-specific settings

---

## 5. Reusability

One of the biggest advantages of modules is reuse.

Instead of writing PostgreSQL resources repeatedly for:

```text
environment/dev
environment/staging
environment/prod
```

all environments can consume the same PostgreSQL module.

```text
             modules/postgres
                    │
       ┌────────────┼────────────┐
       ▼            ▼            ▼
      Dev         Staging       Prod
```

The implementation remains consistent while environment-specific values are provided through variables.

The same principle applies to DNS.

---

## 6. Maintainability

Without modules, a large root configuration can become difficult to navigate:

```text
main.tf
├── VNet
├── Subnets
├── NSGs
├── DNS
├── PostgreSQL
├── VMs
├── Public IPs
├── Application Gateway
├── Key Vault
├── App Configuration
└── Identity
```

As the infrastructure grows, the file becomes harder to review and maintain.

With modules:

```text
modules/
├── network/
├── dns/
├── postgres/
├── vm/
├── application-gateway/
├── key-vault/
├── app-configuration/
└── identity/
```

Each component has a defined boundary.

---

## 7. Testing and Validation

Modules make infrastructure easier to validate.

For example, you can review the PostgreSQL module specifically for database security:

```text
PostgreSQL Module
├── Private networking
├── Backup configuration
├── TLS configuration
├── Storage
├── High availability
└── Access configuration
```

The DNS module can separately be reviewed for:

```text
DNS Module
├── Correct zone
├── Correct VNet link
├── Correct records
└── Correct dependencies
```

This makes security reviews and code reviews more focused.

---

## 8. Security Boundaries

Modules can also make security responsibilities clearer.

For example:

```text
                    Internet
                       │
                       ▼
              Application Gateway
                       │
                       ▼
                  Backend VM
                       │
                       ▼
                 PostgreSQL
```

The PostgreSQL module can enforce database-layer decisions such as:

- Private access
- No unnecessary public exposure
- Secure authentication
- Backup configuration
- Appropriate network integration

The DNS module can provide the private name resolution required by the private database endpoint.

This helps keep security decisions close to the infrastructure component they protect.

---

## 9. Modules Should Not Be Too Small

Modularization does **not** mean:

> Create one module for every Terraform resource.

That would create unnecessary complexity.

For example, creating separate modules for:

```text
postgres-server
postgres-storage
postgres-backup
postgres-network
```

may be excessive if these resources form one coherent PostgreSQL component.

A better boundary is:

```text
postgres/
├── server
├── database configuration
├── networking integration
└── related database settings
```

The module should represent a meaningful infrastructure component.

---

## 10. Dependency Management

Modules also make dependencies easier to understand.

For example:

```text
Networking
   │
   ├──────────────► DNS
   │                 │
   │                 ▼
   └──────────────► PostgreSQL
```

The PostgreSQL module can consume:

```hcl
subnet_id           = module.network.subnet_ids["database"]
private_dns_zone_id = module.dns.private_dns_zone_id
```

Terraform can then understand the dependency graph through resource references.

This is generally preferable to manually forcing dependencies everywhere with `depends_on`.

Use `depends_on` when Terraform cannot infer a real dependency from the resource references.

---

## 11. Root Module vs Child Modules

A useful rule is:

### Root module

The root module should describe **the architecture**.

```hcl
module "network" {
  source = "../../modules/network"
  # ...
}

module "dns" {
  source = "../../modules/dns"
  # ...
}

module "postgres" {
  source = "../../modules/postgres"
  # ...
}
```

### Child modules

Child modules should describe **how each infrastructure component is implemented**.

For example:

```text
modules/postgres/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

The root says:

> "I need a PostgreSQL database connected to this private subnet."

The module handles:

> "How should Azure PostgreSQL Flexible Server be configured?"

---


The infrastructure layers become:

```text
                         Internet
                            │
                            ▼
                 Application Gateway
                            │
                            ▼
                       Backend/App
                            │
                            ▼
                  Private PostgreSQL
                            │
                            ▼
                    Azure PostgreSQL
```

Supporting services:

```text
                  ┌───────────────┐
                  │      DNS      │
                  └───────────────┘
                          │
                          ▼
                 Private name resolution


                  ┌───────────────┐
                  │   Key Vault   │
                  └───────────────┘
                          │
                          ▼
                  Secrets management
```

---

## 13. Key Principle

The main reason to create DNS and PostgreSQL as modules is **separation of concerns**.

A good Terraform module should:

1. Have one clear responsibility.
2. Hide implementation details.
3. Expose only the inputs that callers need.
4. Return useful outputs.
5. Be reusable across environments.
6. Make security and dependencies easier to review.
7. Avoid unnecessary coupling with unrelated infrastructure.

Therefore:

> **DNS belongs in a DNS module because DNS is an independent infrastructure responsibility.**

> **PostgreSQL belongs in a PostgreSQL module because the database is an independent infrastructure component with its own configuration, lifecycle, networking, and security requirements.**

This results in infrastructure that is easier to **understand, reuse, review, test, secure, and maintain**.
