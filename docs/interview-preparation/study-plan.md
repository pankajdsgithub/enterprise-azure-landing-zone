# 30-day hands-on plan
| Days | Focus | Output |
|---|---|---|
| 1-3 | Phases 1-4: prerequisites, Terraform, Git, remote state | Working bootstrap; explain state locking aloud |
| 4-6 | Phase 5: management groups + policy (or subscription-scope policy) | Compliance report; explain 4 policy effects |
| 7-9 | Phases 6-7: hub, spoke, peering | Draw the topology from memory |
| 10-11 | Phase 8: firewall lab (≤ 4 h) then destroy | Trace spoke-to-spoke packet flow with effective routes |
| 12-14 | Phase 9: private endpoints and DNS | Reproduce the "resolves public" failure and fix it |
| 15-16 | Phase 10: identity, RBAC, federated credentials | Explain WIF without notes |
| 17-19 | Phase 11: three-tier app | Deploy and destroy cleanly |
| 20-21 | Phases 12-13: monitoring, backup, DR design | KQL queries; RPO/RTO table |
| 22-24 | Phase 14: Azure DevOps pipelines | Pipeline with approval gate |
| 25 | Troubleshooting guide: break and fix 5 issues deliberately | Incident notes |
| 26-27 | Terraform vs Bicep; write one resource in Bicep | Honest positioning script |
| 28 | Mock LLD defence (record yourself) | Gaps list |
| 29 | Scenario drill: 15 scenarios, 3 minutes each | |
| 30 | Full mock interview + review of weak areas | |

# The 20 concepts to explain without notes
1. Landing zone, platform vs application LZ · 2. Management group hierarchy and policy inheritance · 3. Subscription design and environment segregation · 4. Hub-spoke topology and non-transitive peering · 5. UDR/route precedence, spoke-to-spoke via firewall · 6. NSG vs Azure Firewall vs Bastion · 7. Private Endpoint + Private DNS resolution flow · 8. ExpressRoute vs VPN, gateway transit · 9. Entra roles vs Azure RBAC, least privilege, PIM · 10. Managed identities (system vs user) · 11. Workload identity federation · 12. Policy effects (Audit/Deny/Modify/DINE) and remediation · 13. Key Vault RBAC and secret handling · 14. Terraform state, backend, locking, isolation, recovery · 15. `count` vs `for_each`, dynamic blocks, module design · 16. Provider/Terraform version pinning and lock file · 17. CI/CD flow: validate → plan artifact → approval → apply · 18. Central logging (diagnostic settings, DCR, LAW) · 19. Backup vs ASR vs availability zones; RPO/RTO · 20. Terraform vs Bicep trade-offs and honest positioning.
