# Phase 15: Validation and testing

## Objective
Prove each requirement is met.

## Architecture explanation
Walk the LLD §28 table; record evidence for sign-off.

## Prerequisites
All previous phases.

## Files to create / use (already in the repository)
`scripts/validate-all.sh`, `scripts/check-module-wiring.py`

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
bash scripts/validate-all.sh
python3 scripts/check-module-wiring.py
pip install checkov && checkov -d . --framework terraform --quiet --compact
cd application && terraform plan -var-file=../environments/dev/terraform.tfvars -var-file=../environments/dev/platform.auto.tfvars -detailed-exitcode   # exit 0 = no drift
az policy state summarize
```

## Expected output
`validate` success, Checkov summary, plan exit code 0 (idempotency).

## Azure Portal verification
Policy compliance %, Network Watcher Connection troubleshoot, Defender recommendations.

## Troubleshooting
Drift on second plan -> a provider default/computed value; add `lifecycle.ignore_changes` only for justified attributes.

## Interview questions (answers in `docs/interview-preparation/`)
- How do you test Terraform?
- What is configuration drift and how do you detect it?
- What would you automate in post-deployment validation?

## Important concepts to remember
Idempotency; `-detailed-exitcode`; static analysis vs plan vs integration tests (terraform test / Terratest).
