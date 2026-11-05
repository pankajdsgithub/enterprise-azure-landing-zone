# Phase 03: Identity and RBAC

## Objective
Create the identity baseline and least-privilege RBAC model for platform operations.

## Manual Steps
1. identify the automation identities and platform admin roles
2. validate the managed identity or service principal setup
3. assign RBAC at the proper scope
4. confirm group-based access is used where possible

## Repository Mapping
This aligns with the platform identity root and the RBAC assignment configuration in the repo.

## Validation
- verify role assignments exist only at the intended scope
- validate signs of least privilege and no broad wildcard assignments
- confirm no secrets are stored in repository code

## Exit Criteria
The platform and automation identities can operate without risky or overly broad permission sets.
