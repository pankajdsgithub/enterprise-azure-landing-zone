#!/usr/bin/env bash
# Static validation of every root module and child module (no Azure access needed, needs provider download).
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
terraform -chdir="$REPO" fmt -check -recursive
for d in "$REPO"/modules/* "$REPO"/platform/* "$REPO/application"; do
  [[ -d "$d" ]] || continue
  ls "$d"/*.tf >/dev/null 2>&1 || continue
  echo "==> validate $d"
  terraform -chdir="$d" init -backend=false -input=false >/dev/null
  terraform -chdir="$d" validate
done
