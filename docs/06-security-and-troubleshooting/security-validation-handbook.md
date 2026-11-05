# Security Validation Handbook

## Objective
Validate that the implemented landing zone meets the minimum security expectations for governance, access control, and platform protection.

## Security Checks
- verify Azure RBAC is least privilege
- review management group and subscription boundaries
- validate that public access is limited as intended
- confirm tags, policies, and exemptions are aligned to the design
- verify state and pipeline security controls are in place

## Review Pattern
Security validation should occur before deployment and after implementation so that drift is identified early.

## Exit Criteria
The environment is demonstrably aligned to the intended secure design and does not expose unnecessary control-plane risks.
