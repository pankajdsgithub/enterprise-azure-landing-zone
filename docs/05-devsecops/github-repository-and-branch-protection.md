# GitHub Repository and Branch Protection

## Objective
Protect the repository and ensure review-quality changes are made before code is merged into shared branches.

## Mandatory Controls
- require pull requests for main and release branches
- require at least one reviewer
- require status checks to pass
- disallow direct pushes to protected branches
- require signed commits or equivalent governance where possible

## Suggested GitHub Settings
- default branch: main
- branch protection enabled for `main`
- required checks: Terraform validation, security scan, and lint jobs
- allow only repository admins to override in exceptional cases

## Operational Outcome
Repository governance reduces drift and ensures that landing zone changes are reviewed and validated before deployment.
