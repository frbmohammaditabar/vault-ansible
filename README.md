# HashiCorp Vault Deployment Guide

Author: Fariba Mohammaditabar
Last Updated: 2025-09-13

## 1. Installation with Ansible (Rocky Linux VM)

We use Ansible for automated installation of HashiCorp Vault on Rocky Linux.

### Prerequisites

* Ansible control node with SSH access to target VM
* Root or sudo privileges on the target VM
* Terraform (optional) if provisioning infrastructure on Hetzner/Cloud

### Example Ansible Playbook

`install_vault_ansible.yaml`

Run the playbook:

```bash
ansible-playbook -i inventory install_vault_ansible.yaml
```

## 2. Initialization and Unsealing

After installation, log into the Vault VM and initialize:

```bash
vault operator init
```

* Save the **unseal keys** and **root token** securely.
* Unseal the Vault:

```bash
vault operator unseal
```

## 3. Structure (Post-Deployment Design)

We design the Vault structure around:

* Environments
* Auth methods
* Secrets engines
* Policies

See the `vault-structure/` directory for details.

## 4. Future: Helm Chart Deployment (HA Mode on Kubernetes)

For high availability, Vault can be deployed on Kubernetes with Helm.

### Prerequisites

* Kubernetes cluster (K8s or OpenShift)
* Helm installed

### Install Vault with Helm

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault --namespace vault --create-namespace \
  --set "server.ha.enabled=true" \
  --set "server.ha.raft.enabled=true"
```

### Initialize Vault in HA Mode

After pods are ready:

```bash
kubectl exec -it vault-0 -- vault operator init
kubectl exec -it vault-0 -- vault operator unseal
```
