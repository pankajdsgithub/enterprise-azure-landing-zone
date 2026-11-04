# Azure security and Entra ID questions (batch 1: 10 of the 30 target)
**Q1. Entra roles vs Azure RBAC?** Directory roles manage Entra objects; RBAC manages Azure resources. Separate systems (bridge: elevate access).
**Q2. System- vs user-assigned MI?** System: tied to one resource lifecycle; user: standalone, reusable, pre-authorisable.
**Q3. Workload identity federation?** An external OIDC token (ADO/GitHub/AKS) is exchanged for an Entra token based on a federated credential (issuer+subject); no secret to leak/rotate.
**Q4. Key Vault RBAC vs access policies?** RBAC is the current model: consistent with Azure RBAC, per-secret scope, PIM-capable; access policies are legacy.
**Q5. PIM?** Just-in-time eligible role activation with MFA, approval, justification, time limit, audit.
**Q6. Conditional Access?** Policy engine on sign-in signals (user, device, location, risk) → grant/block controls. Break-glass accounts excluded.
**Q7. Defender for Cloud: CSPM vs CWP?** Posture management/recommendations vs workload protection plans (paid).
**Q8. Encryption at rest options?** Platform-managed keys (default), customer-managed keys in Key Vault/HSM, infrastructure (double) encryption, encryption at host.
**Q9. How do you stop public exposure?** Policy deny public IP/public network access, private endpoints, firewall egress, Defender recommendations.
**Q10. Least privilege in CI/CD?** Dedicated identity per environment, Contributor at subscription (or RG) only, no Owner, branch-controlled approvals.
