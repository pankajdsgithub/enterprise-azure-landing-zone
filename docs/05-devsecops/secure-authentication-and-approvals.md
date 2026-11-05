# Secure Authentication and Approvals

## Objective
Keep auth secure and auditable while allowing controlled deployment approvals.

## Authentication Model
Use:
- managed identities or federated credentials
- OIDC-based GitHub or Azure DevOps authentication
- least privilege roles for deployment identity

## Approval Model
- require manual approval for production or shared platform changes
- separate approvers by environment and change risk
- treat shared control-plane changes as higher risk than dev-sandbox changes

## Pipeline Rule
Never use embedded secrets or long-lived credentials in repository YAML unless explicitly approved by the platform owner.

## Exit Criteria
Authentication, authorization, and review controls are documented, traceable, and enforced by policy.
