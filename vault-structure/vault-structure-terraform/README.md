# Vault Terraform Module Guide

**Author:** Fariba Mohammaditabar  
**Last Updated:** 2025-09-13

This project contains a **Terraform module** for creating HashiCorp Vault paths for Internal Users, Customers, Private Vault, and Development environments.

## Features

* Build Vault paths for Internal Users per location
* Build Customer paths per location
* Create optional Private Vault paths
* Create optional Development/testing paths
* Fully compatible with Vault KV v2 secrets engine

## Prerequisites

* Terraform >= 1.5
* Vault installed and running
* Vault token with root/admin privileges
* Vault address (VAULT_ADDR)

## Module Usage

Example `example-usage.tf`:

```hcl
module "vault_dcdus" {
  source         = "./modules/vault-structure"
  vault_addr     = "http://192.168.x.x:8200"
  vault_token    = "s.YourVaultRootTokenHere"
  location       = "DCDUS"
  customers      = ["Customer1", "Customer2", "Customer3"]
  enable_private = true
  enable_dev     = true
}

module "vault_dcmg" {
  source      = "./modules/vault-structure"
  vault_addr  = "http://192.168.x.x:8200"
  vault_token = "s.YourVaultRootTokenHere"
  location    = "DCMG"
  customers   = []
}
Variables
vault_addr : Vault server address

vault_token: Vault token with sufficient privileges

location : Location/Datacenter name (e.g., DCDUS, DCMG)

customers : List of customers for which paths will be created

enable_private : (bool) create Private Vault paths

enable_dev : (bool) create Development paths

Run the Module
bash
Copy code
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
Verification
Log into Vault and check paths:

bash
Copy code
vault kv get secret/DCDUS/internal/server_management/admin_xcc
vault kv get secret/DCDUS/Customer/Customer1/user_management/placeholder
vault kv get secret/private/User1/placeholder
vault kv get secret/development/tests/placeholder
Directory Structure
css
Copy code
vault-structure-terraform/
├── modules/
│   └── vault-structure/
│       └── main.tf
├── example-usage.tf
└── README.md
Notes
Modify the variables in example-usage.tf to fit your environment.

The module automatically creates all combinations of internal users per location.

Private Vault and Development paths are optional and controlled by boolean flags.

Works with Vault KV v2 secret engine only.
