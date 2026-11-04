# Phase 09: Private Endpoints and Private DNS

## Objective
Verify private access to Key Vault, Storage and SQL.

## Architecture explanation
Done by `application/security.tf` and `database.tf`; DNS zone group writes the A record; zones are linked to hub and spoke.

## Prerequisites
Phase 6/7 complete.

## Files to create / use (already in the repository)
`modules/private-endpoint`, `modules/private-dns`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
# from a VM inside the spoke (az vm run-command or Bastion)
nslookup <kv-name>.vault.azure.net
nslookup <storage>.blob.core.windows.net
# from your laptop (should NOT reach):
curl -sS -m 5 https://<kv-name>.vault.azure.net/ || echo blocked
```

## Expected output
Inside: private 10.x.0.192/27 address. Outside: name resolves to public IP but access denied.

## Azure Portal verification
Private endpoint > DNS configuration; zone > Record sets (A records).

## Troubleshooting
Resolves to public IP inside VNet -> zone not linked to the VNet or custom DNS not forwarding to 168.63.129.16. Connection `Pending` -> manual approval resource. 403 from Terraform creating secrets -> vault is private; run from inside the network.

## Interview questions (answers in `docs/interview-preparation/`)
- Explain DNS resolution for a Private Endpoint step by step.
- Why central private DNS zones?
- How to resolve privatelink names from on-prem?

## Important concepts to remember
CNAME to privatelink zone; A record in private zone; 168.63.129.16; conditional forwarders / DNS Private Resolver for on-prem.
