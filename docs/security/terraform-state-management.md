# Terraform state management

| Topic | Implementation |
|---|---|
| Backend | `azurerm` partial configuration: `terraform init -backend-config=<file>` (never hard-code account names/keys) |
| Bootstrap | `platform/bootstrap-state` with local state; creates RG, GRS storage, 4 containers, delete lock |
| Auth | `use_azuread_auth = true` (Entra ID); storage shared keys **disabled**; needs `Storage Blob Data Contributor` |
| Locking | Native blob **lease** on the state blob; `-lock-timeout=5m` in CI; no separate lock table |
| Isolation | Containers `tfstate-platform`, `tfstate-dev|qa|prod`; each root has its own key (`governance.tfstate`, `connectivity.tfstate`, ..., `application.tfstate`). Enterprise: separate storage accounts per environment/subscription |
| Backup/recovery | Blob versioning + 30-day soft delete + GRS. Restore: list versions `az storage blob list --include v ...`, promote a prior version, re-run `plan` |
| Security | Private network rules + IP allow-list (lab); production: Private Endpoint to the state account + self-hosted/Managed DevOps agents. State contains secrets → treat as secret, restrict RBAC, never commit |
| Migration | `terraform init -migrate-state -backend-config=...` (local→remote or between accounts); `terraform state mv` for refactors; `moved {}` blocks preferred |
| Concurrency | Lease prevents two writers; pipelines queue per environment; use `force-unlock <id>` only after confirming the run is dead |
| Recovery from lock | `az storage blob lease break` is the last resort when `force-unlock` fails |
