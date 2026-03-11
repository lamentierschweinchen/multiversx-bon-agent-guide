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

ascii_to_hex() {
  printf '%s' "$1" | xxd -p -c 9999 | tr -d '\n'
}

whole_egld_to_atomic() {
  perl -Mbigint -e 'print $ARGV[0] * 10**18' "$1"
}

decimal_to_hex() {
  perl -Mbigint -e 'printf "%x", $ARGV[0]' "$1"
}

require DELEGATION_MANAGER_ADDRESS
require PROVIDER_NAME
require PROVIDER_WEBSITE
require PROVIDER_GITHUB
require TOTAL_CAP_EGLD
require SERVICE_FEE_BPS
require CREATE_PROVIDER_EGLD
require TOP_UP_EGLD

cap_atomic="$(whole_egld_to_atomic "$TOTAL_CAP_EGLD")"
create_value_atomic="$(whole_egld_to_atomic "$CREATE_PROVIDER_EGLD")"
top_up_atomic="$(whole_egld_to_atomic "$TOP_UP_EGLD")"

cap_hex="$(decimal_to_hex "$cap_atomic")"
fee_hex="$(decimal_to_hex "$SERVICE_FEE_BPS")"
name_hex="$(ascii_to_hex "$PROVIDER_NAME")"
website_hex="$(ascii_to_hex "$PROVIDER_WEBSITE")"
github_hex="$(ascii_to_hex "$PROVIDER_GITHUB")"

create_data="createNewDelegationContract@${cap_hex}@${fee_hex}"
metadata_data="setMetaData@${name_hex}@${website_hex}@${github_hex}"
delegate_data="delegate"

cat <<EOF
Battle of Nodes transaction payloads

[1] Create staking provider
Receiver: ${DELEGATION_MANAGER_ADDRESS}
Value: ${create_value_atomic}
GasLimit: 60000000
Data: ${create_data}

[2] Set metadata
Receiver: ${DELEGATION_CONTRACT_ADDRESS:-<fill after provider creation>}
Value: 0
GasLimit: 2000000
Data: ${metadata_data}

[3] Top up provider to reach 2500 EGLD total
Receiver: ${DELEGATION_CONTRACT_ADDRESS:-<fill after provider creation>}
Value: ${top_up_atomic}
GasLimit: 12000000
Data: ${delegate_data}

[4] Stake node
Receiver: ${DELEGATION_CONTRACT_ADDRESS:-<fill after provider creation>}
Value: 0
GasLimit: 7000000
Data: stakeNodes@${BLS_PUBLIC_KEY:-<fill BLS public key>}

Notes:
- Name currently configured as: ${PROVIDER_NAME}
- The BON task requires the provider name to end with BoN.
- If BON uses a different delegation manager address, update .env before sending anything.
- The stake transaction assumes one node. For N nodes, gas is 1000000 + N*6000000 and the data is stakeNodes@BLS1@BLS2...
EOF
