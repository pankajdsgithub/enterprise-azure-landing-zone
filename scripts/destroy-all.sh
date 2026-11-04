#!/usr/bin/env bash
# Destroys in REVERSE dependency order. Review each plan; locks must be removed first (enable_delete_lock=false).
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
read -rp "Environment to destroy (dev|qa|prod): " ENVN
read -rp "Type DESTROY to continue: " OK; [[ "$OK" == "DESTROY" ]] || exit 1
"$REPO/scripts/tf-run.sh" application "$ENVN" init
"$REPO/scripts/tf-run.sh" application "$ENVN" destroy
echo "Application destroyed. Platform layers (connectivity, management, governance) are shared: destroy them manually only when ALL environments are gone."
