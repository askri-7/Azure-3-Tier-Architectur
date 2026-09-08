# Secure Login Demo: Enterprise 3-Tier Azure Infrastructure

<img src="/.assets/azure.png" width="40%" alt="Azure">


<img src="/.assets/terraform.png" width="40%" alt="Terraform">

<img src="/.assets/githubaction.png" width="40%" alt="github">

Architected and provisioned **3-tier** enterprise cloud infrastructure on Azure using Terraform to host the **'secure-login-demo'** web ecosystem. Built to rigorous production-grade standards, the platform implements a strict Zero-Trust DevSecOps architecture using modern DevSecOps principles.

## 🚀 Key Architectural Principles
* **Network Segmentation:** Isolated subnets bounded by strict Network Security Groups (NSGs) ensuring zero direct access from the internet to backend or database layers.
* **Least Privilege Access:** Absolute removal of long-lived access keys, relying entirely on Azure Role-Based Access Control (RBAC) and System-Assigned Managed Identities.
* **Centralized Secret & Config Management:** Complete decoupling of configuration from code using Azure App Configuration and Azure Key Vault with secure Key Vault References.

---

<img src="/.assets/arch.jpg" width="40%" alt="github">


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

