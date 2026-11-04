# Phase 11: Compute and application infrastructure

## Objective
Deploy web/app VMs, SQL, Key Vault, storage, optional ILB.

## Architecture explanation
Web and app tiers from one `for_each` map; SQL uses Entra-only auth; all PaaS private.

## Prerequisites
SSH public key, Entra admin group object ID.

## Files to create / use (already in the repository)
`application/compute.tf`, `database.tf`, `security.tf`, modules `virtual-machine`, `azure-sql`, `key-vault`, `storage-account`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
export TF_VAR_admin_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
export TF_VAR_sql_entra_admin_login="grp-sql-admins"
export TF_VAR_sql_entra_admin_object_id="$(az ad group show -g grp-sql-admins --query id -o tsv)"
cd application && terraform apply dev.tfplan   # after re-planning with the above
```

## Expected output
VMs without public IPs, SQL server with public access disabled.

## Azure Portal verification
VM > Networking: no public IP; SQL > Networking: public access disabled; Key Vault > Access control: RBAC.

## Troubleshooting
SKU not available in region -> choose another `vm_size`. `EncryptionAtHost` not registered -> leave disabled or register the feature. Storage `403` on create with private-only account -> run from allowed IP/self-hosted agent.

## Interview questions (answers in `docs/interview-preparation/`)
- Why disable password authentication?
- VMSS vs VMs? when?
- Load Balancer vs Application Gateway?

## Important concepts to remember
`for_each` over a map; conditional resources with `count`; module composition; managed identity for access.
