# Phase 13: Backup and DR

## Objective
Deploy VM backup; understand ASR.

## Architecture explanation
Backup deployed by `module.backup`. ASR is documented only (needs target region VNet, cache storage account, vault in target region, runbooks).

## Prerequisites
VMs from phase 11.

## Files to create / use (already in the repository)
`modules/backup`; ASR design below

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
az backup job list -g <rg> -v <vault> -o table
az backup protection backup-now -g <rg> -v <vault> -c <container> -i <item> --retain-until 31-12-2026
```
**ASR design (not deployed):** Recovery Services vault in South India; enable replication per VM; target RG/VNet pre-created; recovery plan ordering DB -> app -> web; test failover into isolated VNet quarterly; RPO ~ minutes (crash-consistent 5 min, app-consistent 60 min), RTO per recovery plan.

## Expected output
Backup job `Completed`.

## Azure Portal verification
Recovery Services vault > Backup items; Backup jobs.

## Troubleshooting
`UserErrorGuestAgentStatusUnavailable` -> VM agent unhealthy. Policy V2 requires instant restore 1-5 days.

## Interview questions (answers in `docs/interview-preparation/`)
- RPO vs RTO?
- Backup vs ASR vs availability zones?
- How do you test DR?

## Important concepts to remember
Availability zones = HA within region; ASR = DR to another region; backup = recovery from corruption/deletion.
