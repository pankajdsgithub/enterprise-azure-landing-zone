# Phase 06: Hub VNet and network infrastructure

## Objective
Deploy the hub with shared/management subnets, NSGs, private DNS.

## Architecture explanation
`platform/connectivity` creates hub VNet 10.0.0.0/23, reserves GatewaySubnet, NSGs on shared/mgmt subnets, central Private DNS zones. Firewall/Bastion remain OFF.

## Prerequisites
Phase 4; LAW ID if you already ran management (optional).

## Files to create / use (already in the repository)
`platform/connectivity/*`, `modules/vnet`, `modules/nsg`, `modules/private-dns`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd platform/connectivity
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=../../environments/dev/backend.hcl -backend-config="container_name=tfstate-platform" -backend-config="key=connectivity.tfstate"
terraform fmt -recursive && terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

## Expected output
Outputs: hub_vnet_id, hub_vnet_name, private_dns_zone_ids, firewall_private_ip = null.

## Azure Portal verification
VNet > Subnets (6 incl. GatewaySubnet); Private DNS zones x3 > Virtual network links (hub).

## Troubleshooting
`AddressSpaceOverlap` later when peering -> overlapping CIDRs; fix IP plan. `NetcfgInvalidSubnet` for AzureFirewallSubnet -> must be /26 or larger and exactly named.

## Interview questions (answers in `docs/interview-preparation/`)
- Why is GatewaySubnet created before a gateway?
- What subnet size does Azure Firewall need?
- Why no NSG on AzureFirewallSubnet?

## Important concepts to remember
Reserved subnet names; NSG rules default (65000/65001/65500); VNet address planning is hard to change later.
