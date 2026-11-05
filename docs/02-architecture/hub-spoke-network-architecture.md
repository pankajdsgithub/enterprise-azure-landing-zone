# Hub-Spoke Network Architecture

## Goal
Establish a secure and centralized networking pattern in which workloads connect through a common hub and shared services layer.

## Core Pattern
- hub VNet provides shared services and transit
- spokes host application or workload resources
- VNet peering enables connectivity between hub and spoke
- route tables and NSGs enforce egress and ingress control

## Key Design Points
- use separate address spaces for each environment or spoke
- avoid overlapping ranges across the connected network design
- centralize firewall and routing in the hub
- keep private endpoints and DNS in the platform path

## Manual Validation Checklist
- check CIDR ranges for overlap
- confirm routing tables point to the required next hop
- review NSG rules for compliance and least privilege
- validate that private endpoint resolution is aligned with private DNS zones

## Operational Outcome
The result is a cleaner network security posture with centralized inspection and better manageability at scale.
