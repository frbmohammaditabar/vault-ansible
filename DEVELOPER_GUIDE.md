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


## Developer workflow for change password or secret(step by step)
1. Authenticate with role_id + secret_id
```bash
curl --request POST \
    --data '{"role_id":"<ROLE_ID>", "secret_id":"<SECRET_ID>"}' \
    http://127.0.0.1:8200/v1/auth/approle/login
```

Response:
```bash
{
  "auth": {
    "client_token": "hvs.xxxxxx",
    "policies": ["dev-policy"],
    "lease_duration": 3600,
    "renewable": true
  }
}
```

## Now the developer has a Vault token (client_token).

2. Use the token to generate a new secret_id (rotate password)
```bash
curl \
    --header "X-Vault-Token: hvs.xxxxxx" \
    --request POST \
    http://127.0.0.1:8200/v1/auth/approle/role/dev-flask/secret-id
```

Response:
```bash
{
  "data": {
    "secret_id": "s.NEW_SECRET_ID",
    "secret_id_accessor": "…"
  }
}
```

## The developer now has a new secret_id.
They can store it and use it with the same role_id for future logins.

# Notes

Role-ID can be rotated with a POST to /role-id.

Secret-ID can be generated anytime with POST to /secret-id.

Secret-ID can be revoked/destroyed when you want to invalidate it.
