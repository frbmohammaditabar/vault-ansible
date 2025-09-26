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
Vault Logical Structure
Vault uses KV v2 secret engine mounted at secret/.

Locations
DCMG
DCDUS1
DCDUS2
DCTPA
DCSIN
DCIAH
DCSCL
HETZNER
Structure per Location
secret/data// infrastructure/ networking_components/ internal/ server_management/ admin_xcc/ host_management/ root/ vm_management/ root/ administrator/ domadmin/ user_management/ ndbadm/ SYSTEM/ B1SYSTEM/ B1SiteUser/ Customer/ <customer_name>/ server_management/ host_management/ vm_management/ user_management/

Other Vault Areas
Private Vault
user1/
user2/
user...
Development
tests/
...


# Secrets Access

After running the playbooks, the AppRole credentials are saved on the Vault server in /root/vault_creds/:

role_id.txt

secret_id.txt

vault_token.txt

## Notes

Ensure firewalld allows Vault port (default: 8200) on the server.

The Vault UI is accessible at http://<VAULT_IP>:8200/ui.

Keep your /root/vault_creds/ secure; these files grant full acces



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
