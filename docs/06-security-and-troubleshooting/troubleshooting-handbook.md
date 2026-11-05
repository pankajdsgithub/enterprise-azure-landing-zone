# Troubleshooting Handbook

## Scope
This guide captures the most likely operational issues during Azure landing zone implementation and platform validation.

## Common Issues
- authorization or permission failures
- provider not registered or resource provider unavailable
- overlapping CIDR or network address conflicts
- policy assignment causing blocked changes
- Terraform validation or schema errors

## Troubleshooting Method
1. confirm the exact Azure tenant and subscription scope
2. validate user or service principal permissions
3. confirm the resource provider and security baseline
4. inspect the plan output and config drift
5. review whether the issue is architectural or implementation-specific

## Recommended Evidence Collection
- screenshot of the Azure error
- terraform plan output
- relevant resource group or policy state
- validation logs from pipeline or local CLI runs

## Outcome
The issue should be resolved with root-cause evidence rather than reactive configuration churn.
