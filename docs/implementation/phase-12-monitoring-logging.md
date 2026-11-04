# Phase 12: Monitoring and logging

## Objective
Central workspace, activity logs, DCR, alerts.

## Architecture explanation
Deploy `platform/management` first, then feed its workspace ID to the application. Cross-subscription diagnostics write to the one workspace.

## Prerequisites
Email for alerts.

## Files to create / use (already in the repository)
`platform/management/*`, `modules/log-analytics`, `modules/monitoring`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd platform/management && terraform init ... -backend-config="key=management.tfstate" && terraform apply
az monitor log-analytics query -w <workspaceId> --analytics-query "AzureActivity | take 5"
az monitor log-analytics query -w <workspaceId> --analytics-query "Heartbeat | summarize count() by Computer"
```

## Expected output
Rows from `AzureActivity` (after ~15 min) and `Heartbeat` for VMs.

## Azure Portal verification
LAW > Logs; Monitor > Alerts; Action groups; Application Insights > Overview.

## Troubleshooting
No Heartbeat -> AMA extension failed or DCR association missing; check `/var/log/azure/`. Daily cap reached -> raise `daily_quota_gb`.

## Interview questions (answers in `docs/interview-preparation/`)
- How do you centralise logs across 50 subscriptions?
- Diagnostic settings vs agent-based collection?
- Metric alert vs log alert?

## Important concepts to remember
Resource logs vs metrics vs activity log; DCR + AMA replaces the legacy MMA agent; policy DINE for diagnostics at scale.
