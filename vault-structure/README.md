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
