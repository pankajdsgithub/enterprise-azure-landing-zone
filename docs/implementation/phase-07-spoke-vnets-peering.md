# Phase 07: Spoke VNets and peering

## Objective
Deploy the Dev spoke (then QA/Prod) peered to the hub.

## Architecture explanation
`application/` creates spoke VNet, NSGs and **both** peering directions (hub side uses the `connectivity` provider alias).

## Prerequisites
Hub outputs from phase 6; optional LAW from phase 12 (needed as variable).

## Files to create / use (already in the repository)
`application/networking.tf`, `modules/vnet-peering`, `environments/dev/*`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd application
# create environments/dev/platform.auto.tfvars (gitignored) with hub + LAW values
terraform init -backend-config=../environments/dev/backend.hcl
terraform plan -var-file=../environments/dev/terraform.tfvars -var-file=../environments/dev/platform.auto.tfvars -out=dev.tfplan
terraform apply dev.tfplan
```
Set `enable_compute=false enable_database=false` first for a cheap network-only run.

## Expected output
Peerings `peer-dev-to-hub` and `peer-hub-to-dev`.

## Azure Portal verification
Hub VNet > Peerings: status `Connected`, gateway transit as configured.

## Troubleshooting
Peering `Initiated` only -> one side missing/failed (provider alias subscription wrong or no Network Contributor on hub). `RemoteVnetHasOverlappingAddressSpace`.

## Interview questions (answers in `docs/interview-preparation/`)
- Is VNet peering transitive?
- What do allow_forwarded_traffic / gateway transit / use_remote_gateways do?
- How do spokes in different subscriptions peer?

## Important concepts to remember
Peering is non-transitive; both sides required; spoke-to-spoke needs NVA + UDR or vWAN.
