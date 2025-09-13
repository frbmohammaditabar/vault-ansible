module "vault_dcdus" {
  source         = "./modules/vault-structure"
  vault_addr     = var.vault_addr
  vault_token    = var.vault_token
  location       = "DCDUS"
  customers      = ["Customer1","Customer2","Customer3"]
  enable_private = true
  enable_dev     = true
}

module "vault_dcmg" {
  source      = "./modules/vault-structure"
  vault_addr  = var.vault_addr
  vault_token = var.vault_token
  location    = "DCMG"
  customers   = []
}
