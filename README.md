## HashiCorp Vault Ansible Automation

Author: Fariba Mohammaditabar
Last Updated: 2025-09-26

## Installation with Ansible (Rocky Linux VM)

We use Ansible for automated installation of HashiCorp Vault on Rocky Linux.

### Prerequisites

* Ansible control node with SSH access to target VM
* Root or sudo privileges on the target VM
* Terraform (optional) if provisioning infrastructure on Hetzner/Cloud


This repository provides Ansible playbooks and roles to deploy, configure, and manage HashiCorp Vault in a repeatable and automated way.
It supports:

- Installing Vault service on Rocky Linux

- Initializing and unsealing Vault

- Enabling AppRole authentication with custom policies

- Creating a structured secrets path for isolated access

- Exporting credentials for developers to consume via API

##  Repository Structure
```bash
.
├── inventory                    # Ansible inventory (Vault VM hosts)
├── site.yaml                    # Main entry point to run roles
├── install_vault.yaml           # Role wrapper for Vault installation
├── init_unseal.yaml             # Role wrapper for init & unseal
├── approle_policy.yaml          # Role wrapper for Approle & Policy
├── vault_structure.yaml         # Role wrapper for secrets structure
├── roles/
│   ├── install_vault/           # Install and configure Vault service
│   ├── init_unseal/             # Initialize & unseal Vault, store creds
│   ├── approle_policy/          # Enable AppRole and configure policies
│   └── vault_structure/         # Manage secrets engine & structure
└── README.md
```

## Usage
1. Define inventory

Edit the inventory file and specify your Vault server host(s):
```yaml
[vault]
10.9.104.227 ansible_user=terraform ansible_port=60022
```
2. Run playbooks step by step

Run all playbooks in order using the main site.yaml
```bash
ansible-playbook -i inventory site.yaml
```

This will execute all roles in the correct order:

Install Vault (install_vault role)

Initialize & unseal Vault (init_unseal role)

Enable AppRole and set policies (approle_policy role)

Create structured secrets paths (vault_structure role)

# Optional: Run standalone playbooks

You can also run individual playbooks for testing or partial setup:
```bash
ansible-playbook -i inventory install_vault.yaml
ansible-playbook -i inventory init_unseal.yaml
ansible-playbook -i inventory approle_policy.yaml
ansible-playbook -i inventory vault_structure.yaml
```

Recommended only for testing; site.yaml ensures correct order and dependencies.


Install Vault
```bash
ansible-playbook -i inventory install_vault.yaml
```
Initialize & Unseal Vault

This generates unseal keys and root token, saved securely in /opt/vault/credentials.txt on the server.
```bash
ansible-playbook -i inventory init_unseal.yaml
```
Configure AppRole & Policies

Prints RoleID and SecretID for application usage.
```bash
ansible-playbook -i inventory approle_policy.yaml
```
Create Secrets Structure
```bash
ansible-playbook -i inventory vault_structure.yaml
```
# Secrets Access

After running the playbooks, the AppRole credentials are saved on the Vault server in /root/vault_creds/:

role_id.txt

secret_id.txt

vault_token.txt

## Notes

Ensure firewalld allows Vault port (default: 8200) on the server.

The Vault UI is accessible at http://<VAULT_IP>:8200/ui.

Keep your /root/vault_creds/ secure; these files grant full acces



## Developer Guide – Using Vault
# Login via AppRole

Developers can authenticate with Vault using RoleID and SecretID:
```bash
curl --request POST \
     --data '{"role_id":"<ROLE_ID>","secret_id":"<SECRET_ID>"}' \
     http://<VAULT_IP>:8200/v1/auth/approle/login
```

Developers can use these credentials to access secrets via Vault API or CLI.
```flask
Example: Using Python (Flask)
import hvac

client = hvac.Client(
    url='http://<VAULT_IP>:8200',
    role_id=open('role_id.txt').read().strip(),
    secret_id=open('secret_id.txt').read().strip()
)

login = client.auth_approle('role_id', 'secret_id')
secrets = client.secrets.kv.v2.read_secret_version(path='secret/data/DCMG/internal/server_management/admin_xcc')
print(secrets['data']['data'])
```


This returns a client token (client_token) that can be used to access secrets.

# Read Secrets

Example: Fetch a secret stored under secret/data/myapp/config:
```bash
curl --header "X-Vault-Token: <CLIENT_TOKEN>" \
     http://<VAULT_IP>:8200/v1/secret/data/myapp/config
```
# Example in Python (Flask)
import requests
```bash
VAULT_ADDR = "http://<VAULT_IP>:8200"
ROLE_ID = "<ROLE_ID>"
SECRET_ID = "<SECRET_ID>"
```
# Authenticate
```bash
resp = requests.post(f"{VAULT_ADDR}/v1/auth/approle/login",
                     json={"role_id": ROLE_ID, "secret_id": SECRET_ID})
client_token = resp.json()["auth"]["client_token"]
```
# Read secret
```bash
secret = requests.get(f"{VAULT_ADDR}/v1/secret/data/myapp/config",
                      headers={"X-Vault-Token": client_token}).json()
print(secret)
```

In Vault AppRole, you don’t really “change” the role_id or secret_id like a password. Instead, you regenerate them with the Vault API. Here’s how:

# 1. Get Current Role-ID
```bash
curl \
  --header "X-Vault-Token: <root_or_admin_token>" \
  http://<VAULT_ADDR>:8200/v1/auth/approle/role/<ROLE_NAME>/role-id
```
# 2. Regenerate Role-ID

If you want a new Role-ID:
```bash
curl \
  --request POST \
  --header "X-Vault-Token: <root_or_admin_token>" \
  http://<VAULT_ADDR>:8200/v1/auth/approle/role/<ROLE_NAME>/role-id
```

 This will rotate the role-id (the old one becomes invalid).

# 3. Generate a New Secret-ID

You can generate as many secret_ids as you want, each valid until it expires or is revoked.
```bash
curl \
  --request POST \
  --header "X-Vault-Token: <root_or_admin_token>" \
  --data '{"metadata": {"user":"developer1"}}' \
  http://<VAULT_ADDR>:8200/v1/auth/approle/role/<ROLE_NAME>/secret-id
```

This returns:
```bash
{
  "request_id": "xxxx",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "secret_id": "e3f2-xxxx-xxxx",
    "secret_id_accessor": "1234-xxxx-xxxx"
  }
}
```
# 4. Revoke a Secret-ID

If you want to “change password” behavior (invalidate old secret-id):
```bash
curl \
  --request POST \
  --header "X-Vault-Token: <root_or_admin_token>" \
  --data '{"secret_id":"<old_secret_id>"}' \
  http://<VAULT_ADDR>:8200/v1/auth/approle/role/<ROLE_NAME>/secret-id/destroy
```

# Notes

Role-ID can be rotated with a POST to /role-id.

Secret-ID can be generated anytime with POST to /secret-id.

Secret-ID can be revoked/destroyed when you want to invalidate it.


##  Customization

Update roles/*/vars/main.yaml for your organization’s secrets path, policies, and environment-specific configuration.

Add more roles under roles/ as your Vault usage expands.

## Security Notes

Never commit generated credentials (unseal keys, root tokens, RoleID, SecretID) to Git.

Rotate secrets regularly.

Restrict access to this repository if it contains sensitive configurations.

## Roadmap

 - Add TLS configuration for Vault

 - Integrate with Consul/RAFT for HA setup

 - Add CI/CD pipeline examples for secret injection
