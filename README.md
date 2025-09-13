# HashiCorp Vault Deployment Guide

## 1. Installation with Ansible (on Rocky Linux VM)

We use **Ansible** for automated installation of HashiCorp Vault on Rocky Linux.

### Prerequisites
- Ansible control node with SSH access to target VM  
- Root or sudo privileges on the target VM  
- Terraform (optional) if provisioning infrastructure on Hetzner/Cloud  

### Example Ansible Playbook (`install_vault_ansible.yaml`)
Run the Playbook
ansible-playbook -i invnetory install_vault_ansible.yaml
2. Initialization and Unsealing

After installation, log into the Vault VM and initialize:

vault operator init


Save the unseal keys and root token securely.
Unseal the Vault:

vault operator unseal

3. Structure (Post-Deployment Design)

We will design the Vault structure around environments, auth methods, secrets engines, and policies.

See vault-structure Directory

4. Future: Helm Chart Deployment (HA Mode on Kubernetes)

For high availability, we deploy Vault on Kubernetes with Helm.

Prerequisites

Kubernetes cluster (K8s or OpenShift)

Helm installed

Install Vault with Helm
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault hashicorp/vault --namespace vault --create-namespace \
  --set "server.ha.enabled=true" \
  --set "server.ha.raft.enabled=true"

Initialize Vault in HA

After pods are ready:

kubectl exec -it vault-0 -- vault operator init
kubectl exec -it vault-0 -- vault operator unseal

---
