# Management Group Architecture

## Purpose
Management groups provide the policy and governance boundary for the Azure landing zone hierarchy. This repository models a platform-first control plane where governance is centralized and inherited by child scopes.

## Reference Design
A typical structure is:
- Tenant Root
  - Platform
    - Connectivity
    - Management
    - Identity
  - Landing Zones
    - Non-Production
    - Production
  - Sandbox
  - Decommissioned

## Why This Structure Matters
- centralizes policy assignments
- separates platform and workload owners
- enables production guardrails without blocking developer experimentation
- supports future enterprise growth and governance models

## Manual Implementation Steps
1. review current management groups in the tenant
2. confirm which groups should host platform services vs landing zones
3. ensure policy inheritance is aligned with business ownership
4. avoid placing workloads directly at the root if governance needs to be enforced consistently

## Validation
Use Azure Portal or CLI to confirm the hierarchy is present and that policy inheritance is active.
