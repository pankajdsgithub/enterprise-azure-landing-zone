# Tenant and Subscription Discovery

## Why This Matters
A landing zone depends on a valid tenant hierarchy, management group model, and subscription arrangement. Discovery reduces the chance of creating resources in the wrong Azure boundary.

## Discovery Actions
1. List the current Azure tenant and subscriptions.
2. Confirm the billing and ownership model.
3. Identify current management group inheritance.
4. Note existing policy and security baselines.
5. Confirm the environment model: dev, QA, prod, shared platform.

## Azure CLI Workflow
```bash
az login
az account list -o table
az account show --query "{name:name, id:id, tenantId:tenantId, environment:environment}" -o json
az account management-group list -o table
```

## Review Points
- confirm whether management groups already exist
- identify any pre-existing enterprise-scale landing zone components
- check for reserved subscription names, quotas, or cost center constraints
- confirm whether the customer expects one subscription or a platform-plus-landing-zone split

## Output
Document the target model in a simple architecture record:
- tenant id
- subscription id(s)
- management group structure
- region selections
- environment ownership

## Decision Gate
Only proceed to Terraform deployment once the tenant boundaries and subscription intent are validated and agreed by the project owner.
