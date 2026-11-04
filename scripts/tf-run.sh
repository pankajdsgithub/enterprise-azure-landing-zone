#!/usr/bin/env bash
# Local helper: ./scripts/tf-run.sh <root-dir> <env|none> <init|plan|apply|destroy>
# Example: ./scripts/tf-run.sh application dev plan
set -euo pipefail
ROOT="${1:?root dir (e.g. application, platform/connectivity)}"
ENVN="${2:?env (dev|qa|prod|none)}"
ACTION="${3:?init|plan|apply|destroy}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO/$ROOT"
VARS=()
BACKEND=()
if [[ "$ENVN" != "none" ]]; then
  [[ -f "$REPO/environments/$ENVN/terraform.tfvars" ]] && VARS+=("-var-file=$REPO/environments/$ENVN/terraform.tfvars")
  [[ -f "$REPO/environments/$ENVN/platform.auto.tfvars" ]] && VARS+=("-var-file=$REPO/environments/$ENVN/platform.auto.tfvars")
  BACKEND+=("-backend-config=$REPO/environments/$ENVN/backend.hcl")
fi
case "$ACTION" in
  init)    terraform init "${BACKEND[@]}" ;;
  plan)    terraform plan "${VARS[@]}" -out=tfplan ;;
  apply)   terraform apply tfplan ;;
  destroy) terraform destroy "${VARS[@]}" ;;
esac
