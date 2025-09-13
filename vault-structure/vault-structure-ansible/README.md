# Vault Automation with Ansible

This project contains a set of **Ansible playbooks** for installing and configuring **HashiCorp Vault** and building a logical structure for paths including Internal Users, Customers, Private Vault, and Development.

## Features

- Install and enable the `secret/` mount point using kv-v2
- Build paths for Internal Users
- Build paths for Customers
- Create Private Vault paths for specific users
- Create Development and testing paths
- Verify the Vault structure

## Requirements

- Ansible >= 2.10
- HashiCorp Vault installed and running
- `jq` (optional, for JSON parsing)
- Vault token with root/admin access

## Inventory

Example inventory file:

```ini
[vault_servers]
vault-0 ansible_host=127.0.0.1

## Playbooks

1. Setup Vault Structure

vault-setup.yaml

Cleans and enables the secret/ mount point

Builds Internal Users, Customers, Private Vault, and Development paths

Uses shell commands and simple loops without nested list comprehension

Run the playbook:

ansible-playbook -i inventory vault-setup.yaml

2. Verify Vault Structure

vault-verify.yaml

Checks the important paths created in Vault

Displays status for each path: OK or MISSING

Run the playbook:

ansible-playbook -i inventory vault-verify.yaml

## Directory Structure
.
├── inventory
├── vault-setup.yaml
├── vault-verify.yaml
└── README.md

## How It Works

vault-setup.yaml playbook first ensures that the secret/ mount point exists and is enabled.

Then it creates all defined paths for Internal Users, Customers, Private Vault, and Development.

vault-verify.yaml playbook checks all critical paths and reports their status.

## Notes

Make sure Vault is running and you have access to a valid VAULT_TOKEN before running the playbooks.

Placeholder values in the paths can be replaced with real usernames, passwords, or secrets.

You can customize the structure by modifying the variables locations, internal_users, customers, private_vault_users, and development_paths.
