# PROJECT_STATUS

_Last updated: 2026-11-04 (batch 1)_

## Validation status (honest record)
| Check | Result |
|---|---|
| `tofu fmt -check -recursive` (OpenTofu 1.8.5 used as formatter only) | **PASS** |
| `scripts/check-module-wiring.py` (module inputs/outputs/variables resolve; negative-tested) | **PASS** |
| `terraform validate` against azurerm schema | **NOT RUN** - provider registry unreachable in the authoring sandbox. Run `bash scripts/validate-all.sh` locally; expect to fix some schema nits |
| `terraform plan` / `apply` against Azure | **NOT RUN** - no deployment performed. Nothing here is "tested in Azure" |
| Checkov | **NOT RUN** |
| Pipelines YAML | not executed; syntax unverified by Azure DevOps |

## Completed
- Repo scaffold, `.gitignore`, pinned versions (`terraform ~> 1.9`, `azurerm ~> 4.14`, `azuread ~> 3.0` in the optional example)
- 18 modules with all 5 required files: resource-group, management-group, vnet (includes subnets), nsg, route-table, vnet-peering, azure-firewall, private-endpoint, private-dns, key-vault, storage-account, log-analytics, monitoring, azure-policy, managed-identity, virtual-machine, azure-sql, backup
- Platform roots: bootstrap-state, governance (MGs + 4 custom policies + initiative + assignments), connectivity (hub, NSGs, optional Firewall/Bastion, central Private DNS), management (LAW, action group, activity log, optional Defender), identity (pipeline UAMI + federated credentials + RBAC)
- `application/` three-tier root + dev/qa/prod tfvars
- 3 pipelines + 2 templates (OIDC, approvals, Checkov, saved-plan apply)
- Docs: LLD (31 sections, 8 Mermaid diagrams), 16 phase guides, packet flows, governance prerequisites, state management, troubleshooting (14 areas), cost guide, Terraform vs Bicep, 15 scenarios, study plan + 20 concepts, scripts

## Pending
| Item | Note |
|---|---|
| Interview bank | 54 of 210+ Q&As written (target: 50 LZ, 50 TF, 30 NW, 30 Sec, 30 ADO, 30 LLD, 20 customer) |
| VPN gateway / ExpressRoute | architecture documented (`packet-flows.md`); **no Terraform module** yet; ER stays optional/non-simulated |
| Azure Site Recovery | design documented only (phase 13); no Terraform |
| Application Gateway / VMSS variant | only VM + optional internal LB implemented |
| Network Watcher resources | referenced only (data source disabled with `count = 0`) |
| Phase docs | reference repo files instead of pasting full code; add expected-output samples after a real deployment |
| Diagram ↔ code audit | done by hand once; re-check after `validate` fixes |
| Tests | add `terraform test` for modules |

## Known limitations / risks to verify first
1. Schema drift: arguments were written for azurerm 4.x from memory without schema validation (e.g. firewall policy `dns`, SQL `azuread_administrator`, backup policy V2, `default_outbound_access_enabled`).
2. `application/` has a potential logical coupling (VM ↔ monitoring DCR ↔ alerts); Terraform should resolve it (no true cycle expected) - confirm with `plan`.
3. Private-only Storage/Key Vault block Terraform data-plane calls from outside the network; use self-hosted agents or a temporary IP allow.
4. Policy built-in lookups use display names (`data.azurerm_policy_definition`); names can change.
5. Tag Contributor role GUID in `require-tag-on-rg-inherit.json` should be verified (`az role definition list --name "Tag Contributor"`).
6. OIDC token lifetime in pipelines may be shorter than a long apply.
7. Firewall SKU/feature set (Basic) has limits (no DNS proxy, no threat intel).
8. Prices in the cost guide are approximations.

## Deployment prerequisites
See phase-01 and `docs/governance/prerequisites.md` (tenant elevation, MG roles, subscriptions, ER circuit, Entra permissions).

## Next steps
1. Run `validate-all.sh` with real providers; fix schema errors.
2. Deploy Dev network-only (`enable_compute=false enable_database=false`), then full.
3. Complete the interview bank and add VPN/ER and ASR modules.
4. Add Checkov baseline/skip file and Infracost to the PR pipeline.
