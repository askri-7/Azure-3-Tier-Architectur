##############################################################################
# environment/dev/terraform.tfvars
#
# Fill in every <CHANGE_ME> before running `terraform plan`.
# Everything else is a sane default for a dev environment and can be left
# as-is on your first apply.
##############################################################################

##############################################################################
# 1. General / naming
##############################################################################

location             = "francecentral"          # <CHANGE_ME> pick your Azure region
resource_group_name  = "isra-rg-01"             # must already exist
storage_account_name = "terrafstorageaccount01" # must already exist (see backend.tf)

# subscription_id is optional here — it falls back to ARM_SUBSCRIPTION_ID.
# Only set it if you want it pinned explicitly in tfvars instead of an env var.
# subscription_id = "<CHANGE_ME-subscription-guid>"

naming = {
  project = "internship" # short project code, used to build resource names
  env     = "dev"
}

tags = {
  project     = "secure-login-demo"
  environment = "dev"
  owner       = "tmtrack"
  managed_by  = "terraform"
}

##############################################################################
# 2. GitHub Actions OIDC — federated identity subjects
#
# Format for each entry: "<any-key-you-like>" = "repo:<org>/<repo>:<qualifier>"
# Qualifier examples:
#   ref:refs/heads/main                -> only the main branch
#   environment:dev                    -> only jobs using the "dev" GH environment
#   pull_request                       -> only PR-triggered runs
# Docs: https://docs.github.com/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
##############################################################################

# Infra pipeline lives in the infra repo (this repo) and runs terraform plan/apply.
infra_federated_subjects = {
  main = "repo:askri-7/Azure-3-Tier-Architectur:ref:refs/heads/main"
  dev  = "repo:askri-7/Azure-3-Tier-Architectur:environment:dev"
}

# Image build/push pipeline lives in the APP repo (secure-login-demo).
app_federated_subjects = {
  main = "repo:askri-7/secure-login-demo:ref:refs/heads/release/3tiervm"
}

# Deploy workflow invokes Run Command on the app VM.
deploy_federated_subjects = {
  dev = "repo:askri-7/Azure-3-Tier-Architectur:environment:dev"
}

# Secret rotation workflow — also defined in this infra repo.
secret_rotation_federated_subjects = {
  rotation = "repo:askri-7/Azure-3-Tier-Architectur:environment:secret-rotation"
}

##############################################################################
# 3. Networking — one VNet, six subnets
#
# 10.20.0.0/16 gives plenty of room; each subnet below is a /24 except
# Bastion (needs to be named exactly "AzureBastionSubnet" by the module,
# minimum /26) and Postgres (delegated subnet, minimum /28).
##############################################################################


address_space = ["10.20.0.0/16"]

ddos_protection_plan = null

app_gateway_cidr_block = "10.20.0.0/24"
web_cidr_block         = "10.20.1.0/24"
app_cidr_block         = "10.20.2.0/24"
postgres_cidr_block    = "10.20.3.0/28"
bastion_cidr_block     = "10.20.4.0/26"
private_cidr_block     = "10.20.5.0/24" # private endpoints subnet (KV + ACR)

# Declared as required by environment/dev/variables.tf but not currently
# consumed by any module — set to an empty list so `plan` doesn't fail.
private_endpoint_security_rules = []

##############################################################################
# 3a. Network Security Group rules
##############################################################################

# --- Web subnet: only Application Gateway traffic in, plus SSH from Bastion ---
web_security_rules = [
  {
    name                       = "Allow-AppGateway-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.20.0.0/24"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.20.4.0/26"
    destination_address_prefix = "*"
  }
]

# --- App subnet: only the web VM can reach the backend port, plus SSH from Bastion ---
app_security_rules = [
  {
    name                       = "Allow-Web-To-App-Backend"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "10.20.1.0/24"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.20.4.0/26"
    destination_address_prefix = "*"
  }
]

# --- Application Gateway subnet: mandatory platform rules for Standard_v2 ---
gateway_security_rules = [
  {
    name                       = "Allow-Internet-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-GatewayManager"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-AzureLoadBalancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
]

# --- PostgreSQL subnet: only the app subnet may connect on 5432 ---
postgres_security_rules = [
  {
    name                       = "Allow-App-To-Postgres"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.20.2.0/24"
    destination_address_prefix = "*"
  }
]

# --- Bastion subnet: standard Microsoft-required rules for AzureBastionSubnet ---
# Reference: https://learn.microsoft.com/azure/bastion/bastion-nsg
bastion_security_rules = [
  {
    name                       = "Allow-Internet-HTTPS-In"
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
    name                       = "Allow-GatewayManager-In"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-AzureLoadBalancer-In"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-BastionHostComms-In"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "Allow-BastionHostComms-In"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "5701"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "Allow-SSH-Out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "Allow-RDP-Out"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  },
  {
    name                       = "Allow-AzureCloud-Out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  },

  {
    name                       = "Allow-HTTP-Out"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
]

##############################################################################
# 4. Web tier (VM behind the Application Gateway)
##############################################################################



web_vm_metadata = {
  size           = "Standard_B2s_v2"
  admin_username = "azureuser"
  computer_name  = "web-vm"
}

web_os_disk = {
  caching              = "ReadWrite"
  storage_account_type = "StandardSSD_LRS"
}

web_source_image = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}

# Paste the CONTENTS of your public key file (e.g. ~/.ssh/id_ed25519.pub)


web_boot_diagnostics = {
  enabled = false
}

##############################################################################
# 5. App tier (VM running backend + Redis via Docker Compose)
##############################################################################

app_vm_metadata = {
  size           = "Standard_B2s_v2"
  admin_username = "azureuser"
  computer_name  = "app-vm"
}

app_os_disk = {
  caching              = "ReadWrite"
  storage_account_type = "StandardSSD_LRS"
}

app_source_image = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}

# Can reuse the same key as the web VM, or generate a separate one.


app_boot_diagnostics = {
  enabled = false
}

##############################################################################
# 6. Application Gateway
##############################################################################

# Must be globally unique in the region — becomes <label>.westeurope.cloudapp.azure.com
domain_name_label = "secure-logy-dm"

# Standard_v2 is required for autoscaling and is what the mandatory
# GatewayManager NSG rule above assumes.
sku_gateway = "Standard_v2"

##############################################################################
# 7. Key Vault
##############################################################################

sku_kv                        = "standard"
purge_protection_enabled      = false # true is safer for prod but blocks quick teardown in dev
public_network_access_enabled = true  # README's documented dev compromise for hosted-runner access

##############################################################################
# 8. Azure Container Registry
##############################################################################

# NOTE: Premium is required — the acr_pe private endpoint module needs it.
# Basic/Standard SKUs cannot use Private Link and terraform apply will fail.
sku_acr = "Premium"

##############################################################################
# 9. PostgreSQL Flexible Server
##############################################################################

postgres_version = "16"
sku_postgres     = "B_Standard_B1ms" # burstable, cheapest tier suitable for dev
storage_mb       = 32768             # 32 GiB, the minimum allowed increment
db_name          = "authdb"          # matches secure-login-demo's DB_NAME expectation

# Display name for the Entra admin principal Terraform assigns (your own
# az login identity, since entra_admin_object_id comes from data.azurerm_client_config.current)
entra_admin_name = "db_admin"