# Infrastructure Secrets Management with HashiCorp Vault

This repository contains the Terraform configuration and Vault logical structure
for managing infrastructure and customer secrets across multiple datacenters.

---

## Vault Logical Structure

Vault uses **KV v2** secret engine mounted at `secret/`.

### Locations

- **DCMG**
- **DCDUS1**
- **DCDUS2**
- **DCTPA**
- **DCSIN**
- **DCIAH**
- **DCSCL**
- **HETZNER**

### Structure per Location

secret/data/<LOCATION>/
infrastructure/
networking_components/
internal/
server_management/
admin_xcc/
host_management/
root/
vm_management/
root/
administrator/
domadmin/
user_management/
ndbadm/
SYSTEM/
B1SYSTEM/
B1SiteUser/
Customer/
<customer_name>/
server_management/
host_management/
vm_management/
user_management/


### Other Vault Areas

- **Private Vault**
  - user1/
  - user2/
  - user...
- **Development**
  - tests/
  - ...

---

## Terraform Integration

Terraform will authenticate to Vault and fetch credentials instead of hardcoding them.

### Provider Configuration

```hcl
provider "vault" {
  address = "https://vault.example.com:8200"
  token   = var.vault_token
}



Example: Reading a Secret

data "vault_generic_secret" "ndbadm" {
  path = "secret/data/DCDUS/Customer/namexyz/usermanagement/ndbadm"
}

output "ndbadm_username" {
  value = data.vault_generic_secret.ndbadm.data["username"]
}

output "ndbadm_password" {
  value     = data.vault_generic_secret.ndbadm.data["password"]
  sensitive = true
}


Vault API Usage



Save a Secret (KV v2)
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"data": {"username":"ndb_admin","password":"S3cretP@ssw0rd"}}' \
     $VAULT_ADDR/v1/secret/data/DCDUS/Customer/namexyz/usermanagement/ndbadm

Get a Secret (KV v2)
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     $VAULT_ADDR/v1/secret/data/DCDUS/Customer/namexyz/usermanagement/ndbadm


Response fields are under .data.data.username and .data.data.password.

Python Example (Webshop Integration)
import requests

VAULT_ADDR = "https://vault.example.com:8200"
VAULT_TOKEN = "s.xxxxx"
path = "DCDUS/Customer/namexyz/usermanagement/ndbadm"

url = f"{VAULT_ADDR}/v1/secret/data/{path}"
resp = requests.get(url, headers={"X-Vault-Token": VAULT_TOKEN}, verify=True)
resp.raise_for_status()

secret = resp.json()["data"]["data"]
print(secret["username"], secret["password"])

Vault Policies

Policies restrict access per role (infrastructure, customer, private, etc.).

Example Policy: Customer User Management (Read-only)
path "secret/data/DCDUS/Customer/*/usermanagement/*" {
  capabilities = ["read", "list"]
}

Example Policy: Internal Admin (Full)
path "secret/data/*/internal/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

Next Steps

Switch Terraform runs from terraform user → kladmin user.

Store all kladmin and terraform credentials in Vault.

Apply Vault policies per location and customer.

Integrate webshop API calls to fetch username/passwords from Vault.

Track progress in OpenProject and push code into GitLab.



---

# 🔹 Sections Separately  

## 1. Terraform Config Example

```hcl
provider "vault" {
  address = "https://vault.example.com:8200"
  token   = var.vault_token
}

data "vault_generic_secret" "kladmin" {
  path = "secret/data/DCMG/internal/host_management/root"
}

output "kladmin_password" {
  value     = data.vault_generic_secret.kladmin.data["password"]
  sensitive = true
}



2. Vault API Examples
Save Secret
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     --request POST \
     --data '{"data": {"username":"kladmin","password":"P@ssw0rd123"}}' \
     $VAULT_ADDR/v1/secret/data/DCMG/internal/host_management/root

Get Secret
curl --header "X-Vault-Token: $VAULT_TOKEN" \
     $VAULT_ADDR/v1/secret/data/DCMG/internal/host_management/root

3. Vault Policy Examples
Customer Access Policy (Read-only to their secrets)
path "secret/data/DCDUS/Customer/namexyz/*" {
  capabilities = ["read", "list"]
}

Infrastructure Admin Policy (Full access internal)
path "secret/data/*/internal/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

Private Vault Policy (Only user1)
path "secret/data/private/user1/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


