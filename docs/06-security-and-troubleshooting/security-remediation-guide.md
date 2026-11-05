# Security Remediation Guide

## Objective
Provide a practical escalation and response pattern when a landing zone control fails or a security issue is discovered.

## Response Workflow
1. confirm the issue and affected scope
2. isolate the affected resource group or platform boundary
3. determine whether the problem is misconfiguration, policy conflict, or unauthorized access
4. apply the minimum corrective action
5. verify the fix with targeted validation

## Typical Remediation Areas
- RBAC overreach or denied access
- policy conflict or unsupported configuration
- network path exposure beyond approved design
- insecure secret or state access pattern

## Governance Rule
Every remediation action should be recorded with: issue, root cause, action taken, validation result, and owner.
