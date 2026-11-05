# Terraform Validation and Security Scanning

## Objective
Validate Terraform changes using code quality gates before they are considered deployable.

## Recommended Checks
- `terraform fmt -recursive`
- `terraform validate`
- module wiring verification
- policy or security scanning for hardcoded secrets and risky patterns
- plan review for potential drift or scope expansion

## Repository Alignment
The repo includes pipeline definitions and script-based wrappers to support these checks.

## Manual Review Points
- check for schema drift or unsupported arguments
- confirm the file path and environment align with the intended deployment
- ensure state and security risks are reviewed before apply

## Output
The deployment should only proceed if the validation and security scan results are green and approved by the responsible team.
