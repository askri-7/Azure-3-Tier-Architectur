# Secure Login Demo: Enterprise 3-Tier Azure Infrastructure

<div style="display: flex; align-items: center; gap: 15px;">
  <img src="/.assets/azure.png" width="10%" alt="Azure">
  <img src="/.assets/terraform.png" width="10%" alt="Terraform">
  <img src="/.assets/githubaction.png" width="10%" alt="github">
</div>

Architected and provisioned **3-tier** enterprise cloud infrastructure on Azure using Terraform to host the **'secure-login-demo'** web ecosystem. Built to rigorous production-grade standards, the platform implements a strict Zero-Trust DevSecOps architecture using modern DevSecOps principles.

## 🚀 Key Architectural Principles
1. 🔐 Least-privilege RBAC
2. 🪪 Managed identities / OIDC
3. 🔑 Key Vault + secret lifecycle
4. 🌐 Private networking and NSGs
5. 🗄️ PostgreSQL security/HA
6. 🐳 ACR and container security
7. ⚖️ Application Gateway/WAF/load balancing
8. 📊 Monitoring and auditing
9. 🏗️ Terraform module boundaries and state security
10. 🔄 Rotation, revocation, backup and recovery
11. 🚀 CI/CD and immutable deployments
---

<img src="/.assets/arch.jpg" width="100%" alt="github">


## 📂 Repository Architecture & Layout

This project isolates reusable infrastructure components (**Modules**) from live configuration environments (**Live Inventory**). State files are intended to be managed strictly within the environment directories.

```text
secure-login-demo-infra/
├── modules/                        # Reusable Blueprints (No state is managed here)
│   ├── network/                    # VNet, Subnets, Private DNS, and NAT Gateway
│   ├── security/                   # NSGs, Key Vault, App Configuration, and RBAC roles
│   ├── shared_services/            # Azure Container Registry (Premium SKU with Private Endpoints)
│   ├── gateway/                    # Application Gateway with WAF configuration
│   ├── web_tier/                   # Frontend Virtual Machine Scale Set & Internal Load Balancer
│   ├── app_tier/                   # Backend API Virtual Machine Scale Set 
│   └── database/                   # Azure PostgreSQL Flexible Server (Primary + Read Replica)
│
└── environments/                   # Live Implementations (Where 'terraform apply' runs)
    ├── dev/                        # Development environment deployment configurations

    │
    └── prod/                       # Production environment deployment configurations

```

---

