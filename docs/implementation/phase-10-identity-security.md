# Phase 10: Identity and security

## Objective
Deploy pipeline identity, RBAC, Defender (opt-in), Entra groups (optional).

## Architecture explanation
`platform/identity` creates a user-assigned managed identity for the pipeline with federated credentials; `platform/management` enables Defender plans only if listed.

## Prerequisites
Entra permissions only for the optional `examples/entra-groups-optional`.

## Files to create / use (already in the repository)
`platform/identity/*`, `platform/management/*`, `modules/managed-identity`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd platform/identity
terraform init -backend-config=../../environments/dev/backend.hcl -backend-config="container_name=tfstate-platform" -backend-config="key=identity.tfstate"
terraform plan -out=tfplan && terraform apply tfplan
```

## Expected output
Output `pipeline_identity_client_id`.

## Azure Portal verification
Managed Identities > id-terraform-pipeline > Federated credentials; role assignments on subscription.

## Troubleshooting
`AADSTS70021 No matching federated identity record` -> issuer/subject mismatch with service connection. `AuthorizationFailed` -> RBAC propagation delay or scope too narrow.

## Interview questions (answers in `docs/interview-preparation/`)
- System-assigned vs user-assigned managed identity?
- Explain workload identity federation.
- Entra roles vs Azure RBAC?
- What is PIM and why?

## Important concepts to remember
No secrets: OIDC token exchange; least privilege; PIM = just-in-time eligible assignments with approval and expiry.
