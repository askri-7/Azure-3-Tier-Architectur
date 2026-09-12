# Azure Three Tier Infrastructure

Terraform infrastructure for a development Azure deployment with separate web, application, and database tiers.

## Current Architecture

This repository currently creates one Azure Virtual Network with dedicated subnets. It is not yet a hub and spoke topology.

```text
Internet
   |
   v
Application Gateway public IP
   |
   v
Web VM in the web subnet
   |
   v
Internal Load Balancer
   |
   v
App VM in the app subnet
   |                  \
   |                   +--> Azure Container Registry
   |                   +--> Azure Key Vault
   v
PostgreSQL Flexible Server
```

The web VM is only the web tier. It does not need database access or Key Vault access. The app VM is the backend runtime and uses its user assigned managed identity to pull images, read required application secrets, and authenticate to PostgreSQL with Microsoft Entra ID.

The app VM can run Docker Compose for backend services such as the API and Redis. Docker Compose runs on the app VM only. It does not span both VMs. The web VM has its own web tier deployment.

## Azure Components

- One virtual network with web, app, Application Gateway, PostgreSQL, Bastion, and private endpoint subnets.
- Network Security Groups for the web, app, gateway, PostgreSQL, and Bastion subnets.
- Application Gateway with a public static IP and HTTP listener.
- One Linux web VM connected to the Application Gateway backend pool.
- One Linux app VM behind an internal load balancer.
- Azure PostgreSQL Flexible Server with Entra authentication and password authentication disabled.
- Azure Container Registry with public access enabled for the current hosted runner model.
- Azure Key Vault with RBAC authorization.
- Private DNS zones and private endpoints for PostgreSQL, Key Vault, and ACR.
- NAT Gateway for app subnet outbound connectivity.
- Azure Bastion for administrative access.
- User assigned identities for the app runtime, infrastructure pipeline, image pipeline, migration pipeline, and secret rotation pipeline.
- Cloud-init bootstrap scripts that install Docker on both VMs.

## Repository Layout

```text
environment/dev/       Live development environment and Terraform state backend
modules/               Reusable Terraform modules
scripts/               Database permission bootstrap SQL
.github/workflows/     Infrastructure, image, migration, and rotation pipelines
```

The environment root composes the modules. The modules do not manage Terraform state independently.

## Identity and Authentication

GitHub Actions uses OIDC. Azure client secrets are not required for the pipelines.

- Infrastructure identity: Terraform plan and apply, state access, and infrastructure changes.
- Image identity: pushes application images to ACR.
- App runtime identity: pulls images, reads approved Key Vault secrets, and connects to PostgreSQL.
- Migration identity: runs Prisma migrations and seed operations.
- Secret rotation identity: creates new Key Vault secret versions.

PostgreSQL password authentication is disabled. Application and migration access use short lived Microsoft Entra access tokens. Database permissions are initialized with `scripts/setup_app_permissions.sql` by the configured PostgreSQL Entra administrator.

## Pipelines

- `iac-pipeline.yml`: Gitleaks, Checkov, Terraform formatting, TFLint, validate, plan, and protected apply.
- `app-ci-cd.yml`: builds and scans an application image and pushes an immutable Git SHA tag to ACR.
- `database-migration.yml`: runs Prisma migration and seed using the migration identity.
- `secret-rotation.yml`: creates a new Key Vault secret version using the rotation identity.

The application image pipeline builds and publishes the image. A separate deployment command is still required to make the app VM pull and run that new image.

## VM Storage and Cloud-init

The web and app VMs are bootstrapped by `scripts/web-cloud-init.yaml` and
`scripts/app-cloud-init.yaml`. Both scripts install Docker, enable the Docker
service, and create application directories under `/opt`.

No managed data disk is currently attached to either VM. Docker and the
application directories therefore use the OS disk. This is suitable for
development bootstrap, but data stored there is lost if the OS disk or VM is
replaced. The Redis data directory is also on the OS disk. Add and mount a
managed data disk before treating application or Redis data as durable
production state.

## Hosted Runner Network Model

The migration and secret rotation workflows use GitHub hosted runners, not self hosted runners. PostgreSQL and Key Vault public network access are enabled so those workflows can reach Azure services.

This is a development compromise. PostgreSQL firewall rules must allow the runner source addresses, and public access increases the network exposure. Entra authentication still applies and PostgreSQL passwords remain disabled. A private runner or another private execution service is preferred for production.

## Validation

Run from `environment/dev`:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
```

Do not run `terraform apply` until the GitHub environment approvals, OIDC subjects, Terraform variables, firewall rules, and database identity grants are configured.