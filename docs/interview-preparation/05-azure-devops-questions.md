# Azure DevOps CI/CD questions (batch 1: 8 of the 30 target)
**Q1. Service connection with WIF vs secret?** WIF = no secret, no expiry management, scoped by subject; secret = rotation burden/leak risk.
**Q2. Why apply a saved plan?** Guarantees what was reviewed is what gets applied.
**Q3. Where do approvals live?** Environments > Approvals and checks (approvals, branch control, business hours, exclusive lock).
**Q4. How do you stop concurrent applies?** Exclusive lock check on the environment + state lease.
**Q5. Pipeline security?** Protect `main`, restrict who edits pipeline YAML, templates from a protected repo, minimal scopes, no secrets in logs, plan artifact access control.
**Q6. Checkov findings you can't fix?** Documented skip with justification (`#checkov:skip=`) and review.
**Q7. Multi-stage YAML vs classic releases?** YAML = versioned, reviewable; classic is legacy.
**Q8. Hosted vs self-hosted agents?** Self-hosted/Managed DevOps pools for private network access (state, Key Vault, private ACR).
