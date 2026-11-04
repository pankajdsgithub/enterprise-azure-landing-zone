# 15 realistic architecture scenarios (model answers, conversational)

Each answer: *what I'd say*, then **follow-ups** to expect.

### 1. Design an enterprise Landing Zone for 50 applications
"I'd start by grouping the 50 apps by criticality, data sensitivity and connectivity needs - not one subscription per app by default. Management groups: Platform (Connectivity, Management, Identity), Landing Zones (Corp non-prod/prod), Sandbox, Decommissioned. Hub-spoke network with a firewall and ExpressRoute in the hub, Private DNS centralised, Policy at management-group level, one log workspace, Terraform with state per layer and a subscription-vending pipeline so a new app subscription arrives pre-wired with peering, DNS links, diagnostics and baseline RBAC." **Follow-ups:** How many subscriptions? (Group by environment + boundary; quotas and blast radius.) How do you onboard app #51?
### 2. Migrate on-prem applications to Azure
"Assess with Azure Migrate (dependency mapping), classify 6Rs, wave-plan by dependency, land in the landing zone, replicate (Azure Migrate/ASR), test in an isolated VNet, cut over with DNS/IP plan, keep rollback to on-prem for an agreed window." **Follow-ups:** Chatty apps across the ER link? Licensing? Data gravity?
### 3. Centralised network connectivity
"Hub VNet in a Connectivity subscription with ER/VPN gateways, Azure Firewall, Bastion, DNS resolver. Spokes peer to hub. Beyond ~hundreds of spokes or multi-region, consider Virtual WAN." **Follow-ups:** Peering limits (500 per VNet)? vWAN vs hub-spoke?
### 4. Secure Private Endpoint connectivity
"Private Endpoint per PaaS resource, public access disabled, private DNS zones central and linked to every VNet, DNS zone group for registration, on-prem resolution via DNS Private Resolver, NSG/firewall policy on flows, policy to deny public access and to deploy DNS records." **Follow-ups:** Why does it resolve public? Cost of 3 endpoints × N?
### 5. Troubleshoot spoke-to-spoke connectivity
"Check in order: peerings Connected both sides and forwarded traffic on; effective routes on the source NIC (is 0.0.0.0/0 → firewall?); firewall logs for a deny; NSGs on both subnets (effective security rules); return-path symmetry; the destination OS firewall; DNS." **Tools:** Network Watcher next-hop, IP flow verify, connection troubleshoot.
### 6. Implement centralised governance
"Policy initiatives at management groups: locations, tags, deny public IP, secure storage, diagnostics via DeployIfNotExists. Roll out in audit, then enforce; exemptions with expiry; compliance dashboards; custom RBAC rare." **Follow-ups:** Policy vs RBAC? Handling an exception?
### 7. Terraform modules for multiple environments
"Small focused modules with validation, one root per layer, environment = tfvars + backend config + separate state, same code promoted dev → qa → prod via pipeline. Avoid workspaces for prod isolation; avoid over-abstraction." **Follow-ups:** Versioning modules? Monorepo vs registry?
### 8. Resolve Terraform state locking issues
"Confirm nobody is running (pipeline, colleague). If a crashed run, `terraform force-unlock <id>`; if that fails, break the blob lease. Then run `plan` to confirm state is intact. Prevent: pipeline concurrency control, lock timeout, state per layer." **Follow-up:** What if state is corrupted? (Versioned blob restore.)
### 9. CI/CD with manual approval
"PR validation (fmt, validate, Checkov), merge triggers plan per env publishing a plan artifact, dev auto-applies, QA/Prod via Environments approvals with branch control, apply uses the saved plan, OIDC service connections, post-deploy checks." **Follow-ups:** Secrets? Hotfix path? Who approves?
### 10. Customer rejects the proposed architecture
"I'd first understand the objection: cost, risk, operating model, or a missing requirement? I'd restate it, tie options back to their requirements with trade-offs (e.g., firewall cost vs. NSG-only), offer a phased approach, update the LLD with a change log and re-baseline." **Follow-up:** What if they insist on something insecure? (Document risk acceptance, escalate to their security owner.)
### 11. High availability and DR
"Zones for in-region HA (zonal VMs, ZRS, zone-redundant SQL, Standard LB), paired-region DR (ASR for VMs, failover group for SQL, GRS), defined RPO/RTO per tier, runbooks and recovery plans, regular DR tests." **Follow-ups:** Region selection; DNS failover with Traffic Manager/Front Door.
### 12. Least-privilege access
"Groups not users; role at narrowest scope; PIM eligibility with approval; custom roles only if built-ins don't fit; managed identities not secrets; access reviews; deny assignments/Policy for guardrails; separate platform vs app roles." **Follow-up:** Owner vs User Access Administrator risk.
### 13. Handle policy conflicts
"Identify which assignment causes the effect (compliance + activity log), evaluate precedence (Deny wins over Audit), fix scope (exclusions, exemption with expiry), or adjust the parameter; never disable globally to unblock one team." **Follow-up:** Policy exemptions vs exclusions.
### 14. Troubleshoot a failed Terraform deployment
"Read the first error, not the last; classify (auth, provider schema, quota, policy, dependency, state); check what actually exists in Azure; re-run plan for the real delta; avoid manual fixes without importing; capture a post-mortem." **Follow-up:** Partial apply - how to recover?
### 15. LLD review and sign-off
"I send the LLD ahead, walk through requirements → design decisions → risks, collect comments in a tracker, version the document, get named approvers to sign the checklist, and treat later changes via change control." **Follow-up:** Which three decisions most need customer buy-in? (IP plan, firewall rules/egress, DR targets.)
