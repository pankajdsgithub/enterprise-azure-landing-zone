# LLD / architecture and customer-facing questions (batch 1)
**Q1. HLD vs LLD?** HLD: concepts, components, decisions; LLD: exact IPs, SKUs, rules, naming, config, sequence - build-ready.
**Q2. What goes in a risk register?** Risk, likelihood, impact, mitigation, owner, status.
**Q3. How do you justify Azure Firewall cost?** Central policy, logging, FQDN control, compliance requirement; offer Basic/NSG-only for non-prod, phase it.
**Q4. Customer says 'make it cheaper' - what do you cut?** Non-prod: Basic SKUs, no zones, shutdown schedules, smaller LAW cap; prod unchanged unless risk accepted in writing.
**Q5. RPO/RTO conversation?** Ask business impact per app tier; map to design (zones, backup, ASR, failover groups); price each tier.
**Q6. How do you handle a requirement you think is wrong?** Explain impact with evidence, offer alternatives, record the decision and risk acceptance.
**Q7. Customer wants public IPs on VMs.** Explain exposure, propose Bastion/Front Door/App Gateway WAF/private access; if still required, time-boxed exemption with compensating controls.
**Q8. How do you get sign-off?** Review sessions, tracked comments, versioned LLD, named approvers on the checklist.
