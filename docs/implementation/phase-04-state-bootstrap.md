# Phase 04: Remote Terraform state bootstrap

## Objective
Create the state storage account (chicken-and-egg solved with local state).

## Architecture explanation
`platform/bootstrap-state` runs once with **local** state, creating RG + GRS storage account (Entra auth only, versioning, 30-day soft delete, firewall deny + your IP, delete lock) with four containers: `tfstate-platform|dev|qa|prod`.

## Prerequisites
Phase 1-3; your public IP (`curl -s ifconfig.me`).

## Files to create / use (already in the repository)
`platform/bootstrap-state/*` (uses `modules/resource-group`, `modules/storage-account`)

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd platform/bootstrap-state
cp terraform.tfvars.example terraform.tfvars   # edit: unique storage_account_name, your IP
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output backend_config_snippet
```
Then for every root create `backend.hcl` from the example (see `environments/README.md`) and migrate:
```bash
cd ../connectivity
terraform init -backend-config=../../environments/dev/backend.hcl   # adjust key/container per root
```

## Expected output
`Apply complete! Resources: ~9 added` and the backend snippet output.

## Azure Portal verification
Storage account > Containers: 4 containers. Settings > Data protection: versioning + soft delete ON. Networking: selected IPs only. Access control: your user has *Storage Blob Data Contributor*.

## Troubleshooting
`AuthorizationPermissionMismatch` on init -> missing data-plane role (RBAC propagation can take 5 min). `403 This request is not authorized` -> your IP changed; update `allowed_ip_rules`. Name taken -> change `storage_account_name`.

## Interview questions (answers in `docs/interview-preparation/`)
- How is state locking implemented for the azurerm backend?
- Why Entra auth instead of access keys for state?
- How would you recover a corrupted state file?
- How do you migrate state from local to remote?

## Important concepts to remember
Blob lease = lock; versioning = recovery; separate containers = blast-radius isolation; `terraform init -migrate-state`; bootstrap state itself is local and small (commit nothing).
