variable "location" { type = string }
variable "customers" { type = list(string) }
variable "enable_private" { type = bool, default = false }
variable "enable_dev" { type = bool, default = false }

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

locals {
  internal_users = {
    server_management = ["admin_xcc"]
    host_management   = ["root"]
    vm_management     = ["root", "administrator", "domadmin"]
    user_management   = ["ndbadm", "SYSTEM", "B1SYSTEM", "B1SiteUser"]
  }
}

# Internal paths
resource "vault_kv_secret_v2" "internal" {
  for_each = { for section, users in local.internal_users : section => users }
  mount    = "secret"
  name     = "${var.location}/internal/${each.key}/${each.value}"
  data_json = jsonencode({ placeholder = "secret" })
}

# Customer paths
resource "vault_kv_secret_v2" "customer" {
  for_each = { for c in var.customers : c => c }
  mount    = "secret"
  name     = "${var.location}/Customer/${each.value}/user_management/placeholder"
  data_json = jsonencode({ placeholder = "secret" })
}

# Private Vault
resource "vault_kv_secret_v2" "private" {
  count = var.enable_private ? 1 : 0
  mount = "secret"
  name  = "private/User1/placeholder"
  data_json = jsonencode({ placeholder = "secret" })
}

# Development
resource "vault_kv_secret_v2" "dev" {
  count = var.enable_dev ? 1 : 0
  mount = "secret"
  name  = "development/tests/placeholder"
  data_json = jsonencode({ placeholder = "secret" })
}
