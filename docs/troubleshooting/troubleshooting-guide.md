# Troubleshooting guide

Format per issue: **Symptom → Root cause → Diagnose → Fix**.

## 1. Terraform authentication failures
- *Symptom:* `Error building ARM Config: obtain subscription() ... az login`, `subscription_id is a required provider property`.
- *Cause:* not logged in / no subscription selected (AzureRM 4.x requires it).
- *Diagnose:* `az account show`; `env | grep ARM_`.
- *Fix:* `az login`; `export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)`. In pipelines: confirm `ARM_USE_OIDC=true`, `ARM_CLIENT_ID`, `ARM_OIDC_TOKEN`, `ARM_TENANT_ID`.
- *OIDC:* `AADSTS70021/700213 No matching federated identity record` → issuer/subject on the federated credential differ from the service connection; copy again (case-sensitive; contains org/project/connection name).

## 2. Provider version issues
- *Symptom:* `Unsupported argument "enable_..."`, `Inconsistent dependency lock file`, `no available releases match`.
- *Cause:* AzureRM 3.x code on 4.x provider (renamed booleans, mandatory subscription_id), or lock file out of date.
- *Diagnose:* `terraform version`, `terraform providers`, `cat .terraform.lock.hcl`.
- *Fix:* `terraform init -upgrade` in a branch, review changelog, commit the lock file. Do not loosen `~> 4.14` casually.

## 3. Backend initialization failures
- *Symptom:* `Error: Failed to get existing workspaces ... 403 AuthorizationPermissionMismatch` or `AuthorizationFailure`.
- *Cause:* (a) missing `Storage Blob Data Contributor`; (b) your IP not in the storage firewall; (c) `use_azuread_auth` missing while keys disabled.
- *Diagnose:* `az role assignment list --assignee <oid> --scope <sa-id>`; `az storage account show -n <sa> --query networkRuleSet`.
- *Fix:* assign role (wait up to 5 min), add IP via `allowed_ip_rules` in bootstrap, set `use_azuread_auth = true`. `Backend configuration changed` → `terraform init -reconfigure` (or `-migrate-state` when you intend to move state).

## 4. State locking problems
- *Symptom:* `Error acquiring the state lock ... lease already present` .
- *Cause:* a running/aborted plan or apply (CI agent killed).
- *Diagnose:* check pipeline runs; `az storage blob show --auth-mode login ... --query properties.lease`.
- *Fix:* wait; else `terraform force-unlock <LOCK_ID>` after confirming nothing is running; last resort `az storage blob lease break`. Prevention: `-lock-timeout`, one pipeline per state.

## 5. Resource already exists
- *Symptom:* `a resource with the ID ... already exists - to be managed via Terraform this resource needs to be imported`.
- *Cause:* created manually or by a failed earlier run whose state was lost.
- *Fix:* `terraform import <addr> <resource-id>` or an `import { to = ..., id = ... }` block (1.5+), then `plan` to confirm zero diff. Globally unique names (KV/Storage/SQL) → change `unique_suffix`. Key Vault in soft-deleted state → `az keyvault recover` or purge.

## 6. RBAC permission failures
- *Symptom:* `AuthorizationFailed ... does not have authorization to perform action`, role assignment `403`.
- *Cause:* identity lacks the action at that scope; creating `azurerm_role_assignment` requires `Microsoft.Authorization/roleAssignments/write` (Owner or User Access Administrator).
- *Diagnose:* `az role assignment list --assignee <id> --all -o table`; the error shows the scope and action.
- *Fix:* grant the narrowest role at the narrowest scope; wait for propagation; for pipelines that must assign roles use *Role Based Access Control Administrator* with a condition.

## 7. Management group permission errors
- *Symptom:* `AuthorizationFailed ... Microsoft.Management/managementGroups/write`.
- *Cause:* MG rights are not inherited from subscription Owner.
- *Fix:* see `docs/governance/prerequisites.md` (elevate access, then Management Group Contributor at root).

## 8. VNet peering failures
- *Symptom:* status `Initiated`/`Disconnected`; `RemoteVnetHasOverlappingAddressSpace`; `use_remote_gateways` error.
- *Cause:* one side missing; overlapping CIDRs; hub has no gateway yet.
- *Diagnose:* `az network vnet peering list -g <rg> --vnet-name <vnet> -o table`.
- *Fix:* create the reverse peering (provider alias/permissions: Network Contributor on hub); fix IP plan; set `hub_has_gateway=false` until a gateway exists.

## 9. DNS resolution issues
- *Symptom:* name resolves to public IP/NXDOMAIN inside VNet.
- *Diagnose:* `nslookup <fqdn>`, `az network private-dns link vnet list -g <rg> -z <zone> -o table`, `az network private-endpoint dns-zone-group list ...`.
- *Fix:* link the zone to the VNet; ensure DNS zone group exists; with custom DNS forward to 168.63.129.16 (or firewall DNS proxy).

## 10. Private Endpoint connectivity
- *Symptom:* timeouts to the PE IP.
- *Cause:* NSG on snet-pe, firewall dropping, PE `Pending`, wrong subresource (`vault`, `blob`, `sqlServer`).
- *Diagnose:* `az network private-endpoint show --query privateLinkServiceConnections[].privateLinkServiceConnectionState`; Network Watcher *Connection troubleshoot*; NSG flow/effective rules (`az network nic list-effective-nsg`).
- *Fix:* approve connection, allow port from source subnets, correct the group ID.
- *Terraform data-plane 403:* creating Key Vault secrets/Storage data with public access off → run from inside the network (self-hosted agent) or temporarily allow your IP.

## 11. Firewall routing issues
- *Symptom:* no internet / one-way traffic.
- *Diagnose:* `az network nic show-effective-route-table`, firewall logs KQL: `AZFWNetworkRule | where Action=="Deny"`.
- *Cause:* missing UDR association, missing allow rule, asymmetric path (one side bypasses firewall), peering forwarded traffic disabled.
- *Fix:* associate route table, add rule, ensure `allow_forwarded_traffic=true` on both peerings, avoid SNAT mismatches.

## 12. Policy deployment failures
- *Symptom:* `RequestDisallowedByPolicy` on apply; assignment errors.
- *Diagnose:* read the policy name in the error; `az policy state list --filter "complianceState eq 'NonCompliant'"`.
- *Fix:* fix the resource to comply (preferred), or create a time-boxed exemption; for new policies start with `enforce=false`. `PolicyDefinitionNotFound` → definition scope must be at/above assignment scope. `InvalidPolicyAssignmentName` → >24 chars at MG scope. Modify/DINE not acting → identity role missing or no remediation task.

## 13. Azure DevOps pipeline failures
- *Symptom:* service connection auth errors, artifact missing, approval never arrives, YAML template errors.
- *Fix:* verify service connection → identity → federated credential; pipeline name in `resources.pipelines.source` must equal the plan pipeline's name; Environments approvals configured; checkout path for `scripts/install-terraform.sh`; agent IP not in state firewall (use self-hosted/Managed DevOps pool in enterprise).

## 14. Terraform plan/apply errors
| Error | Cause | Fix |
|---|---|---|
| `Invalid for_each argument ... depends on resource attributes that cannot be determined until apply` | keys derived from unknown values | use static keys (we do) and put unknowns in values |
| `Cycle:` | mutual dependency | split resources/modules, remove unneeded references |
| `Provider produced inconsistent result` | provider bug/eventual consistency | re-run; pin provider; open issue |
| `SkuNotAvailable` / `QuotaExceeded` | region capacity | change size/region, request quota |
| `Error: Unsupported attribute` | schema mismatch | check provider docs for pinned version |
| `409 ... AnotherOperationInProgress` | parallel operations on same resource | lower `-parallelism`, retry |
| Plan wants to replace VM/disk | immutable argument changed | revert or plan a maintenance window; use `moved` for renames |
