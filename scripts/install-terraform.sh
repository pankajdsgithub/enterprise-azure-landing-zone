#!/usr/bin/env bash
# Installs a pinned Terraform version and verifies its SHA256 checksum.
set -euo pipefail
VERSION="${1:?usage: install-terraform.sh <version e.g. 1.9.8>}"
DEST="${2:-$HOME/.local/bin}"
mkdir -p "$DEST"
BASE="https://releases.hashicorp.com/terraform/${VERSION}"
TMP="$(mktemp -d)"
curl -fsSL -o "$TMP/tf.zip" "$BASE/terraform_${VERSION}_linux_amd64.zip"
curl -fsSL -o "$TMP/SHA256SUMS" "$BASE/terraform_${VERSION}_SHA256SUMS"
( cd "$TMP" && grep "linux_amd64.zip" SHA256SUMS | sed "s/terraform_${VERSION}_linux_amd64.zip/tf.zip/" | sha256sum -c - )
unzip -o -q "$TMP/tf.zip" -d "$DEST"
export PATH="$DEST:$PATH"
terraform version
echo "##vso[task.prependpath]$DEST"
