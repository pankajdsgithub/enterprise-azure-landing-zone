# Phase 03: Git repository setup

## Objective
Create a protected repo with safe ignores.

## Architecture explanation
State, plans and real backend files never enter Git. Branch policy on `main` forces PR validation.

## Prerequisites
Azure DevOps project (or any Git host).

## Files to create / use (already in the repository)
`.gitignore` (already in repo)

## Commands
When to run: `init` once per root (and when providers/backends change); `fmt`/`validate` before every commit; `plan` before every change and review it line by line; `apply` only the reviewed plan; `destroy` only for labs/cleanup.
```bash
cd enterprise-azure-landing-zone
git add -A && git commit -m "Initial landing zone"
git remote add origin <repo-url>
git push -u origin main
git check-ignore -v environments/dev/backend.hcl   # must be ignored
```

## Expected output
`check-ignore` prints the `.gitignore` rule matching `backend.hcl`.

## Azure Portal verification
Azure DevOps > Repos > Branches > `main` > Branch policies: require PR, 1+ reviewer, build validation = terraform-validate.

## Troubleshooting
Push rejected -> branch policy; use a feature branch and PR.

## Interview questions (answers in `docs/interview-preparation/`)
- What must never be committed in a Terraform repo?
- Describe your branching strategy for IaC.
- Mono-repo vs repo-per-module?

## Important concepts to remember
Secrets/state never in Git; protected main; PR = plan review.
