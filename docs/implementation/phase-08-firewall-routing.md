# Phase 08: Firewall and routing

## Objective
OPTIONAL (COST): deploy Azure Firewall Basic and force spoke traffic through it.

## Architecture explanation
Set `enable_firewall=true` in connectivity, then supply `firewall_private_ip` to the spoke so it builds a UDR (0.0.0.0/0 -> firewall).

## Prerequisites
Budget alert configured; plan to destroy within hours.

## Files to create / use (already in the repository)
`modules/azure-firewall`, `modules/route-table`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd platform/connectivity && terraform apply -var enable_firewall=true
terraform output firewall_private_ip
cd ../../application
terraform apply -var-file=../environments/dev/terraform.tfvars -var-file=../environments/dev/platform.auto.tfvars -var firewall_private_ip=<ip>
az network nic show-effective-route-table -g <rg> -n <nic> -o table
```

## Expected output
Effective routes show `0.0.0.0/0` next hop `VirtualAppliance <fw ip>`.

## Azure Portal verification
Firewall > Policy > rule collections; Firewall logs in LAW (`AZFWNetworkRule`).

## Troubleshooting
No internet from VM -> missing application rule or Basic SKU management subnet absent. Asymmetric routing -> a spoke has no UDR while another does. Firewall create fails `AzureFirewallManagementSubnet` -> required for Basic.

## Interview questions (answers in `docs/interview-preparation/`)
- Explain the packet flow spoke-to-spoke.
- Network rules vs application rules vs DNAT?
- Basic vs Standard vs Premium?
- How do you avoid asymmetric routing?

## Important concepts to remember
UDR next hop VirtualAppliance; firewall SNAT; system routes vs UDR vs BGP precedence (UDR > BGP > system for equal prefix length; longest prefix wins first).
