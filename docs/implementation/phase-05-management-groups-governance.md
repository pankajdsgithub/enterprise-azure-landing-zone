# Phase 05: Management groups and governance

## Objective
Build the MG tree and policy baseline.

## Architecture explanation
`platform/governance` creates mg-contoso tree, custom policies (JSON files), an initiative and assignments. Starts with `policy_enforce=false`.

## Prerequisites
Elevated access: Entra Global Admin must enable *Access management for Azure resources*, then assign yourself *Management Group Contributor* and *Resource Policy Contributor* at Tenant Root. Remove afterwards. Not possible in a restricted lab tenant -> skip this phase; the rest works without it.

## Files to create / use (already in the repository)
`platform/governance/*`, `policies/*.json`, `modules/management-group`, `modules/azure-policy`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd platform/governance
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=../../environments/dev/backend.hcl -backend-config="container_name=tfstate-platform" -backend-config="key=governance.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```
Compliance: `az policy state summarize --management-group mg-contoso`

## Expected output
9 management groups, 4 definitions, 1 initiative, ~7 assignments.

## Azure Portal verification
Management groups > hierarchy; Policy > Definitions (filter Custom); Policy > Assignments (scope mg-contoso); Policy > Compliance.

## Troubleshooting
`AuthorizationFailed ... Microsoft.Management/managementGroups/write` -> missing MG role at root. `InvalidPolicyAssignmentName` -> >24 chars (validated in the module). Modify assignment non-compliant but nothing happens -> create a remediation task: `az policy remediation create -n fix-tags --policy-assignment <id> -m mg-contoso`.

## Interview questions (answers in `docs/interview-preparation/`)
- Explain Audit, Deny, Modify, DeployIfNotExists.
- Why does DINE/Modify need a managed identity and remediation?
- Initiative vs definition vs assignment?
- Where do you store custom definitions and why at MG level?
- How do you roll out Deny policies safely?

## Important concepts to remember
Effects order: Disabled, Append/Modify, Deny, Audit, then AuditIfNotExists/DINE. Policy inheritance; `enforce=false` = DoNotEnforce; remediation only fixes existing resources.
