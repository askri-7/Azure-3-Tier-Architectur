# Terraform Modules

These modules are reusable building blocks consumed by `environment/dev`.

## Modules

- `networking`: VNet, six subnets, NSGs, NAT Gateway, public IPs, and Bastion.
- `gateway`: Application Gateway and its public IP.
- `web_tier`: web Linux VM, NIC, managed identity, and Application Gateway association.
- `app_tier`: app Linux VM, NIC, internal load balancer, managed identity, and role assignments.
- `database`: PostgreSQL Flexible Server, Entra authentication, database, and Entra administrator.
- `acr`: Azure Container Registry.
- `keyvault`: Azure Key Vault with RBAC authorization.
- `private-endpoint`: reusable private endpoint and DNS zone group.
- `dns`: private DNS zones and VNet links.
- `workflow-identity`: user assigned identity, GitHub federated credentials, and role assignments.
- `app-configuration`: reusable App Configuration resource. It is currently not instantiated by the dev environment.

## Module Rules

The environment root owns composition and passes IDs between modules. Modules own the resources for one infrastructure responsibility and expose only the outputs required by other modules.

All modules use AzureRM `~> 4.22.0`. Avoid adding credentials to module variables. Use managed identities, Entra authentication, and Key Vault access through RBAC.

## Current Boundaries

The repository has one VNet, not a hub and spoke design. The web and app tiers are separate Linux VMs. Docker Compose, when used, runs on the app VM only. It does not orchestrate both VMs.
