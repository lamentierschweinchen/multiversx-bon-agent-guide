#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
workspace_dir="$(cd "$script_dir/.." && pwd)"
env_file="${workspace_dir}/.env"

if [[ ! -f "$env_file" ]]; then
  echo "missing $env_file; copy .env.example to .env first" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$env_file"

require() {
  local key="$1"
  if [[ -z "${!key:-}" ]]; then
    echo "missing required env var: $key" >&2
    exit 1
  fi
}

require DELEGATION_CONTRACT_ADDRESS
require BLS_PUBLIC_KEY
require BLS_SIGNATURE_HEX

cat <<EOF
Add node transaction payload

Receiver: ${DELEGATION_CONTRACT_ADDRESS}
Value: 0
GasLimit: 7000000
Data: addNodes@${BLS_PUBLIC_KEY}@${BLS_SIGNATURE_HEX}

Reminder:
- The signature must be the delegation contract address signed with the node's secret BLS key.
- This script only assembles the transaction once you already have that signature.
EOF
