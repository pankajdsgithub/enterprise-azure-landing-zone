# Phase 16: Customer handover

## Objective
Close the engagement professionally.

## Architecture explanation
Package the LLD, as-built outputs, runbooks and training.

## Prerequisites
Everything above.

## Files to create / use (already in the repository)
`docs/lld/*`, `docs/troubleshooting/*`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
terraform output -json > as-built-<env>.json   # review for sensitivity before sharing
az resource list --query "[].{n:name,t:type,l:location}" -o table > inventory.txt
```

## Expected output
Signed approval + handover checklist (LLD §31).

## Azure Portal verification
n/a

## Troubleshooting
Customer rejects design -> capture deltas, update LLD version, re-approve; never change production without updated approval.

## Interview questions (answers in `docs/interview-preparation/`)
- How do you run an LLD review with a customer?
- What belongs in a handover pack?
- How do you manage change after go-live?

## Important concepts to remember
Sign-off is a control: LLD is versioned; deviations need change records.
