# Enterprise Greenfield Master Playbook

## Objective
This document is the master operating guide for the Azure Greenfield landing zone implementation in this repository. It provides the delivery context, project assumptions, and the manual execution workflow required to produce a governed Azure foundation using the Terraform assets in this repo.

## Scope
The repository is structured as an enterprise-grade Azure foundation implementation for:
- management groups and governance
- platform identity and RBAC
- hub-and-spoke networking
- private endpoints and DNS
- centralized logging and monitoring
- reusable Terraform modules
- CI/CD validation and policy enforcement

## Delivery Model
The implementation follows a phased model:
1. Discovery and prerequisites
2. Architecture and design validation
3. Platform bootstrap
4. Governance, policy, and identity
5. Connectivity and networking
6. Workload readiness and validation
7. Security and DevSecOps hardening
8. Production readiness and handover

## Repository Alignment
The playbook aligns directly with the repo structure:
- `platform/` for platform roots
- `modules/` for reusable Terraform resources
- `application/` for workload composition
- `environments/` for environment-specific configuration
- `pipelines/` for validation and deployment automation
- `docs/` for design, SOP, and delivery artifacts

## Key Rule
Do not treat this as a one-click deployment. The authoritative process is: validate discovery, verify prerequisites, run plan, review architecture, and only then apply changes in an Azure sandbox or dev environment.

## Manual Execution Principle
Manual onboarding steps complement Terraform automation. Use Azure CLI and Azure Portal to validate tenant access, provider registration, role assignments, enterprise naming conventions, and any preconditions that cannot be determined from a Git repository alone.

## Expected Outcome
The result should be a secure, repeatable Azure landing zone that provides the platform foundation upon which application landing zones can be developed and operated with policy-based governance.
