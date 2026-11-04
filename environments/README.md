# Environments

Each environment is **configuration only** (no Terraform code) for the shared `application/` root module:

| File | Purpose | Committed |
|------|---------|-----------|
| `terraform.tfvars` | Sizing, features, address space | yes |
| `backend.hcl.example` | Template for remote-state settings | yes |
| `backend.hcl` | Real backend settings | **no** |
| `platform.auto.tfvars` | Hub/DNS/LAW outputs, subscription IDs | **no** |

State isolation: one container per environment (`tfstate-dev|qa|prod`) in the bootstrap storage account.

```bash
cd application
terraform init -backend-config=../environments/dev/backend.hcl
terraform plan -var-file=../environments/dev/terraform.tfvars -out=dev.tfplan
```
