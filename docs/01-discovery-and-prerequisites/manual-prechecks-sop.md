# Manual Prechecks SOP

## Objective
Perform manual validation checks before running Terraform or Azure Portal creation tasks.

## Manual Validation Checklist
- verify you are in the correct tenant
- confirm Azure subscription is selected correctly
- review RBAC rights for the user or service principal
- confirm the target resource group naming convention
- confirm the tags and naming standards for the enterprise
- review regional availability and quota
- confirm backup, identity, and security constraints

## Sample Commands
```bash
az account show --output table
az ad signed-in-user show --query "{displayName:displayName, userPrincipalName:userPrincipalName}" -o json
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --all -o table
```

## Network and Security Checks
- confirm no overlapping CIDR ranges with existing networks
- confirm whether private connectivity is required
- check if public access is intentionally prohibited
- verify firewall and egress assumptions

## Governance Checks
- review the management group hierarchy planned in the repo
- confirm the Azure Policy baseline will not disrupt existing production workloads
- review naming conventions for resource groups, VNets, and platform services

## Sign-off
Document the prechecks as evidence before beginning the Terraform apply sequence. If any item fails, stop and remediate before moving forward.
