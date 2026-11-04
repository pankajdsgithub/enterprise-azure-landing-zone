# Governance prerequisites (tenant-level permissions)

Management groups and tenant-root policy need rights above a normal subscription Owner.

1. A **Global Administrator** opens Entra ID > Properties > *Access management for Azure resources* = **Yes** (elevate access; grants User Access Administrator at `/`). CLI: `az rest --method post --url "/providers/Microsoft.Authorization/elevateAccess?api-version=2016-07-01"`.
2. Assign the deployer (user or pipeline identity): `Management Group Contributor` and `Resource Policy Contributor` at the tenant root management group. Assign `User Access Administrator` only if the pipeline manages RBAC.
3. Turn elevation **off** afterwards.
4. Subscription creation (not done by this repo) requires an EA/MCA billing role (`azurerm_subscription` alias creation). Move existing subscriptions with `subscription_associations`.
5. If you cannot obtain these rights (training tenant), skip `platform/governance`, and assign the same policies at subscription scope: use `module "azure-policy"` with `scope_type = "subscription"`.
6. Separate tenant-level resources: Entra groups/PIM settings use the **AzureAD provider** and live in `examples/entra-groups-optional` so they never block subscription deployments.
Also: hierarchy setting "Require authorization for MG creation" and "Default management group" are tenant settings - document, do not automate.
