# Enterprise Azure Landing Zone with Terraform

Hands-on training / interview-preparation project: hub-spoke landing zone, governance, private networking, identity, monitoring, backup and Azure DevOps CI/CD - all in Terraform.

> **Status: work in progress (batch 1).** Read `PROJECT_STATUS.md` first. Code is statically checked (format + wiring) but **has not been deployed to Azure** and `terraform validate` against the real provider schema has **not** been run by the author. Run `scripts/validate-all.sh` and fix any schema issues before deploying.

## Layout
```
modules/        18 reusable modules (main/variables/outputs/versions/README)
platform/       bootstrap-state, governance, connectivity, management, identity (one state each)
application/    one reusable root: networking.tf, security.tf, compute.tf, database.tf, monitoring.tf
environments/   dev|qa|prod tfvars + backend templates (config only)
pipelines/      validate / plan / apply YAML + templates (OIDC, no secrets)
scripts/        install-terraform, tf-run, validate-all, destroy-all, check-module-wiring
docs/           LLD, 16-phase guide, networking, governance, state, troubleshooting, cost, interview
examples/       optional AzureAD (Entra group) example
```
Design decision: the requested `application/{networking,compute,database,monitoring}` folders are **files of one root module**, giving one state per environment without cross-state plumbing. A separate `subnet` module was not created (folded into `vnet`).

## Quick start (cheap lab, single subscription)
```bash
az login && export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
bash scripts/install-terraform.sh 1.9.8
cd platform/bootstrap-state && cp terraform.tfvars.example terraform.tfvars   # edit, then:
terraform init && terraform apply
# then follow docs/implementation/phase-05 ... phase-13 in order
```
Expensive resources (Firewall, Bastion, gateways, ASR, Defender, LB) are **off by default**; see `docs/architecture/cost-optimization.md`.

## Key documents
- `docs/lld/LLD-enterprise-azure-landing-zone.md` - customer-facing LLD with 8 Mermaid diagrams
- `docs/implementation/phase-01 … phase-16` - hands-on guide
- `docs/networking/packet-flows.md`, `docs/governance/prerequisites.md`, `docs/security/terraform-state-management.md`
- `docs/troubleshooting/troubleshooting-guide.md`
- `docs/interview-preparation/` (+ Terraform vs Bicep)
- `docs/interview-preparation/study-plan.md` - 30-day plan and 20 core concepts
