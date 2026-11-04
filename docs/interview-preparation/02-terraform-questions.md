# Terraform questions (batch 1: 14 of the 50 target; answers reference this repo)
**Q1. `count` vs `for_each`?** `count` is index-based (removing item 0 shifts the rest); `for_each` keys by a stable string - used everywhere here (`modules/vnet` subnets).
**Q2. What does `terraform plan` actually do?** Refreshes state, builds the dependency graph, diffs desired config vs state/real world, outputs actions; `-out` saves an exact plan to apply.
**Q3. State locking in azurerm?** Blob lease on the state blob. Concurrent runs fail with a lock error.
**Q4. Why separate state per layer/environment?** Blast radius, permissions, speed; `platform/*` vs `application/` in this repo.
**Q5. How do you avoid secrets in state?** You can't fully (state holds resource attributes) - so restrict state access, use Entra-only auth, avoid passing passwords (SQL Entra-only, SSH keys), ephemeral resources/write-only attributes where supported.
**Q6. `depends_on` - when?** When the dependency is hidden (not expressed by a reference), e.g. `azurerm_private_dns_zone_virtual_network_link` depends on zones created in the same module call by name.
**Q7. Dynamic blocks?** Generate repeated nested blocks from collections: firewall rule collections in `modules/azure-firewall`.
**Q8. Why are `for_each` keys static in `modules/backup`?** Keys must be known at plan time; values (resource IDs) can be unknown.
**Q9. `terraform import` vs `import` block?** Block is declarative, reviewable in plan (1.5+).
**Q10. `moved` blocks?** Refactor addresses without destroy/recreate.
**Q11. How do you version modules?** Git tags / registry with semver; pin `ref=`; this repo uses relative paths for learning.
**Q12. `lifecycle` options?** `prevent_destroy`, `create_before_destroy`, `ignore_changes`, `replace_triggered_by`, `precondition/postcondition`.
**Q13. Terraform Cloud vs Azure DevOps + azurerm backend?** TFC adds managed runs/policy-as-code; ADO is common in Azure shops with private networking needs.
**Q14. Provider alias use?** Two subscriptions in one root: `azurerm.connectivity` in `application/providers.tf` for hub-side peering/DNS links.
