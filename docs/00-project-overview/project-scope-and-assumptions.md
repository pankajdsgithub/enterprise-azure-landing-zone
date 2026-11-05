# Project Scope and Assumptions

## Scope
This project covers the delivery of an Azure greenfield landing zone including:
- tenant and subscription structure
- management groups and governance
- Azure Policy and custom guardrails
- networking, routing, and hub-spoke connectivity
- identity and RBAC baseline
- monitoring and log aggregation
- secure state management and validation automation

## Assumptions
- Azure tenant has the required admin or subscription owner access
- The implementation is performed in a non-production sandbox first
- Optional services such as VPN, ExpressRoute, firewall deep features, and DR remain conditional
- Application resources are intentionally modular and environment-aware
- The project is meant to demonstrate enterprise architecture patterns, not autonomous production go-live without review

## Exclusions
The following are intentionally outside the initial scope unless the client explicitly requests them:
- live production migration cutover
- production-level disaster recovery orchestration
- advanced WAF or edge security services
- multi-tenant or cross-cloud integration patterns
- heavy production tooling complexity beyond what is represented in this repository

## Design Constraints
- follow least privilege by default
- prefer private access and centralized inspection
- design for environmental isolation
- maintain state safely and securely
- keep implementation traceable and reviewable

## Delivery Expectation
The project should be validated in phases, with evidence captured at each step. Every major milestone should have a documented result and a review checkpoint before moving forward.
