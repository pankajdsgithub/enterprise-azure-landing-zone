# Phase 05: Hub-Spoke Networking

## Objective
Deploy the network foundation for the landing zone and establish the shared connectivity model.

## Manual Steps
1. validate CIDR ranges and non-overlap assumptions
2. create the hub VNet and required routing layer
3. create spoke VNet resources and resource groups
4. configure peering, NSGs, and shared network control services
5. review forwarding, egress, and private endpoint traffic paths

## Repository Mapping
This phase maps to the connectivity and networking configuration in the repo.

## Validation
- confirm hub and spoke networks are connected as expected
- review route tables and NSG assignments
- validate private DNS and firewall assumptions, if enabled

## Exit Criteria
The network model is functional, secure, and ready for workload deployment.
