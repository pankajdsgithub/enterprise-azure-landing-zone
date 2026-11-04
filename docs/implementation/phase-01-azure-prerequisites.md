# Phase 01: Azure prerequisites and subscription preparation

## Objective
Have an account, subscriptions and permissions ready; register providers.

## Architecture explanation
Landing zones need subscriptions per role/environment. Training lab: ONE subscription is enough (all `*_subscription_id` variables stay null). Enterprise: Connectivity, Management, Identity, Dev, QA, Prod.

## Prerequisites
Azure account with Owner (lab) or Contributor + User Access Administrator; Entra tenant; Azure CLI >= 2.60.

## Files to create / use (already in the repository)
none (read `docs/governance/prerequisites.md`)

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
az login
az account list -o table
az account set --subscription "<name-or-id>"
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
for p in Microsoft.Network Microsoft.Compute Microsoft.Storage Microsoft.KeyVault Microsoft.Sql Microsoft.OperationalInsights Microsoft.Insights Microsoft.RecoveryServices Microsoft.PolicyInsights Microsoft.Authorization Microsoft.ManagedIdentity Microsoft.Security; do az provider register --namespace $p; done
az provider show -n Microsoft.Network --query registrationState -o tsv
```

## Expected output
`Registered` for each provider (can take a few minutes).

## Azure Portal verification
Portal > Subscriptions > your sub > Resource providers: all `Registered`.

## Troubleshooting
`AuthorizationFailed` on register -> you lack Contributor on the subscription. `az login` token expired -> `az account clear && az login`.

## Interview questions (answers in `docs/interview-preparation/`)
- What is the difference between a tenant, a management group and a subscription?
- Why use multiple subscriptions instead of resource groups for environments?
- What are subscription limits/quotas and how do they affect landing zone design?

## Important concepts to remember
Subscription = billing + RBAC + quota boundary. Resource providers must be registered before use. Never run labs with a production tenant's Owner account when a sandbox exists.
