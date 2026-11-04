# Phase 02: Terraform installation and local setup

## Objective
Install pinned Terraform, verify tooling.

## Architecture explanation
Terraform `~> 1.9` (allows 1.9.x-1.x, blocks 2.0). Version 1.9 is chosen because cross-variable validation (used in `application/variables.tf`) needs >= 1.9. AzureRM `~> 4.14` is 4.x (4.0 removed deprecated arguments such as `enable_*` booleans in favour of `*_enabled`, and made `subscription_id` mandatory). Commit `.terraform.lock.hcl` to pin exact provider builds.

## Prerequisites
Linux/macOS/WSL shell, git, Azure CLI.

## Files to create / use (already in the repository)
none

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
bash scripts/install-terraform.sh 1.9.8 ~/.local/bin
terraform version
az version
```

## Expected output
`Terraform v1.9.8` and Azure CLI version table.

## Azure Portal verification
n/a

## Troubleshooting
Checksum failure -> corporate proxy altering download; download manually and verify SHA256SUMS signature. `terraform: command not found` -> add `~/.local/bin` to PATH.

## Interview questions (answers in `docs/interview-preparation/`)
- Why pin Terraform and provider versions?
- What does `~>` do?
- What is the dependency lock file and should it be committed?

## Important concepts to remember
Pessimistic constraint `~>`; lock file records provider hashes; AzureRM 4.x breaking changes.
