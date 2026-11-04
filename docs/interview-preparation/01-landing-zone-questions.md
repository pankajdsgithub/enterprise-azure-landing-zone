# Azure Landing Zone questions (batch 1: 12 of the 50 target)
**Q1. What is an Azure landing zone?** A pre-configured, governed environment (management groups, subscriptions, network, identity, policy, monitoring) in which workloads are deployed. *Follow-up:* platform vs application landing zone?
**Q2. Platform vs application landing zone?** Platform = shared services (connectivity, identity, management) owned centrally; application = subscription(s) for a workload team, wired to the platform. Different change cadence and ownership.
**Q3. Why management groups?** Inheritance of policy/RBAC at scale above subscriptions; max 6 levels below root (excluding root/subscription); avoid mirroring the org chart - mirror policy and archetype differences.
**Q4. Why not one subscription?** Quota limits, blast radius, RBAC/policy boundaries, billing, environment isolation.
**Q5. Connectivity subscription - what lives there?** Hub VNet, firewall, gateways, Bastion, private DNS, DNS resolver.
**Q6. Hub-spoke vs Virtual WAN?** Hub-spoke: full control, cheaper at small scale, you manage routing. vWAN: managed, transitive routing, scale/multi-region, less custom control and a different cost model.
**Q7. How do you handle subscription vending?** Pipeline that creates the subscription, places it in the MG, creates the spoke VNet + peering, DNS links, diagnostics, baseline RBAC and budgets from a request file.
**Q8. How do you segregate environments?** Separate subscriptions per environment (or at least prod vs non-prod), separate VNets, state, service connections and RBAC.
**Q9. Naming and tagging?** `<type>-<workload>-<env>-<region>-<nnn>`; mandatory tags enforced by policy and inherited via Modify.
**Q10. Where do policies live?** Definitions at the highest MG that needs them (org MG); assignments at the MG where they apply; exemptions at resource/subscription.
**Q11. How do you centralise logging?** One workspace in Management subscription, diagnostic settings (DINE policy) from all subscriptions, Activity Log export, DCRs for VMs.
**Q12. Sandbox management group?** Loose policies, no connectivity to corp, budget caps, for experimentation.
