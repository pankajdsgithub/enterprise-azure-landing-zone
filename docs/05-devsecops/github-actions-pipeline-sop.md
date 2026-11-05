# GitHub Actions Pipeline SOP

## Objective
Use GitHub Actions to standardize validation, planning, and approvals for Terraform-based Azure implementations.

## Recommended Workflow Stages
1. validate formatting and syntax
2. run Terraform validation and module checks
3. perform security scanning
4. generate a Terraform plan
5. require approvals before apply

## Manual Control Points
- identify who can approve production runs
- require environment-specific secrets or workload identities
- ensure OIDC or federated identity is used where possible
- review Terraform plan content before execution

## Operational Principle
The pipeline should act as a control layer, not as a hidden mechanism. Operators must still review the plan and confirm the intended environment and scope.
