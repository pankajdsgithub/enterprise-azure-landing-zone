# Phase 14: Azure DevOps CI/CD

## Objective
Pipelines with workload identity federation, approvals, scanning.

## Architecture explanation
Three pipelines + two templates. OIDC through `AzureCLI@2` (`addSpnToEnvironment`) → `ARM_OIDC_TOKEN`. No client secret anywhere.

## Prerequisites
Phase 10 managed identity or an app registration; Environments `tf-dev|qa|prod`.

## Files to create / use (already in the repository)
`pipelines/*.yml`, `pipelines/templates/*`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
1. Project settings > Service connections > New > Azure Resource Manager > **Workload identity federation (manual)** (or automatic). Name `sc-tf-dev|qa|prod`.
2. Copy *Issuer* and *Subject identifier* into `pipeline_federated_credentials` of `platform/identity`, apply.
3. Grant the identity Contributor on each env subscription and *Storage Blob Data Contributor* on its state container.
4. Pipelines > Environments > `tf-qa`, `tf-prod` > Approvals and checks (approvers; branch control `refs/heads/main`).
5. Library > variable groups `tf-backend` (TF_STATE_RG, TF_STATE_SA), `tf-platform-<env>` (TF_VAR_* hub/DNS/LAW values).
6. Create pipelines from YAML: `terraform-validate`, `terraform-plan`, `terraform-apply` (names must match).

## Expected output
PR runs validate; merge runs plan x3; apply waits for approvals.

## Azure Portal verification
Pipelines run page: stages, artifacts `plan-dev|qa|prod`; Environments > Deployments.

## Troubleshooting
`AADSTS700213` no matching federated identity -> subject mismatch (service connection name/org/project). OIDC token expired mid-apply (~10 min?) -> use `ARM_OIDC_AZURE_SERVICE_CONNECTION_ID` + `ARM_OIDC_REQUEST_TOKEN`/`ARM_OIDC_REQUEST_URL` variant for long applies. State lock held -> `terraform force-unlock <ID>` only after confirming no run is active.

## Interview questions (answers in `docs/interview-preparation/`)
- Why apply the saved plan artifact?
- How do you protect prod?
- Why workload identity federation over client secrets?
- How do you handle concurrent pipeline runs?

## Important concepts to remember
Plan artifacts contain secrets-in-state values: restrict artifact access; approvals via Environments; PR validation required.
