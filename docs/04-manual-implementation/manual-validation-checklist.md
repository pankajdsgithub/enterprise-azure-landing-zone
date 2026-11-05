# Manual Validation Checklist

## Platform Validation
- correct tenant selected
- correct subscription selected
- management groups exist and are aligned to the design
- policies are assigned at the correct scope

## Network Validation
- hub and spoke VNets exist
- routing table and NSG states are correct
- private connectivity and DNS assumptions are reviewed
- no unexpected overlapping ranges are present

## Security Validation
- RBAC assignments are least privilege
- managed identities are configured correctly
- no sensitive values are stored in plain text
- remote state is protected and approved

## Operational Validation
- Log Analytics or monitoring resources are present
- diagnostics are configured where required
- organization support model is documented

## Final Approver Gate
Do not proceed to production or broad deployment until all checks are completed and recorded.
