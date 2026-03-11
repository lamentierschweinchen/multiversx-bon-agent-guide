#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
workspace_dir="$(cd "$script_dir/.." && pwd)"
dry_run_dir="${workspace_dir}/laptop-dry-run"

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing required command: $cmd" >&2
    exit 1
  fi
}

require_command mxpy
require_command perl
require_command sed
require_command awk

mkdir -p "$dry_run_dir"

operator_pem="${dry_run_dir}/operator"
validator_pem="${dry_run_dir}/validatorKey.pem"

if [[ ! -f "$operator_pem" ]]; then
  mxpy wallet new --format pem --outfile "$operator_pem" >/tmp/bon-operator.out
fi

if [[ ! -f "$validator_pem" ]]; then
  mxpy validator-wallet new --outfile "$validator_pem" >/tmp/bon-validator.out
fi

operator_address="$(mxpy wallet convert --infile "$operator_pem" --in-format pem --out-format address-bech32 | awk '/erd1/{print $1; exit}')"

if [[ -z "$operator_address" ]]; then
  echo "could not determine operator address from $operator_pem" >&2
  exit 1
fi

provider_name="${BON_PROVIDER_NAME:-MyProviderBoN}"
provider_website="${BON_PROVIDER_WEBSITE:-https://example.com}"
provider_identifier="${BON_PROVIDER_IDENTIFIER:-your-github-handle}"
chain_id="${BON_CHAIN_ID:-B}"
delegation_manager="${BON_DELEGATION_MANAGER_ADDRESS:-erd1qqqqqqqqqqqqqqqpqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqylllslmq6y6}"
delegation_contract="${BON_DRY_RUN_CONTRACT_ADDRESS:-$operator_address}"

mxpy staking-provider create-new-delegation-contract \
  --pem "$operator_pem" \
  --nonce 0 \
  --chain "$chain_id" \
  --value 1250 \
  --total-delegation-cap 2500 \
  --service-fee 1000 \
  --receiver "$delegation_manager" \
  --outfile "${dry_run_dir}/create-provider.json" >/dev/null 2>&1 || \
mxpy staking-provider create-new-delegation-contract \
  --pem "$operator_pem" \
  --nonce 0 \
  --chain "$chain_id" \
  --value 1250 \
  --total-delegation-cap 2500 \
  --service-fee 1000 \
  --outfile "${dry_run_dir}/create-provider.json" >/dev/null

mxpy staking-provider set-metadata \
  --pem "$operator_pem" \
  --nonce 1 \
  --chain "$chain_id" \
  --delegation-contract "$delegation_contract" \
  --name "$provider_name" \
  --website "$provider_website" \
  --identifier "$provider_identifier" \
  --outfile "${dry_run_dir}/set-metadata.json" >/dev/null

mxpy staking-provider add-nodes \
  --pem "$operator_pem" \
  --validators-pem "$validator_pem" \
  --nonce 2 \
  --chain "$chain_id" \
  --delegation-contract "$delegation_contract" \
  --outfile "${dry_run_dir}/add-nodes.json" >/dev/null

mxpy staking-provider delegate \
  --pem "$operator_pem" \
  --nonce 3 \
  --chain "$chain_id" \
  --delegation-contract "$delegation_contract" \
  --value 1250 \
  --outfile "${dry_run_dir}/delegate-topup.json" >/dev/null

mxpy staking-provider stake-nodes \
  --pem "$operator_pem" \
  --validators-pem "$validator_pem" \
  --nonce 4 \
  --chain "$chain_id" \
  --delegation-contract "$delegation_contract" \
  --outfile "${dry_run_dir}/stake-nodes.json" >/dev/null

"${script_dir}/extract-bls-pubkey.sh" "$validator_pem" > "${dry_run_dir}/bls-public-key.txt"

cat <<EOF
Laptop dry run complete.

Artifacts:
- ${dry_run_dir}/operator
- ${dry_run_dir}/validatorKey.pem
- ${dry_run_dir}/bls-public-key.txt
- ${dry_run_dir}/create-provider.json
- ${dry_run_dir}/set-metadata.json
- ${dry_run_dir}/add-nodes.json
- ${dry_run_dir}/delegate-topup.json
- ${dry_run_dir}/stake-nodes.json

Dry run parameters:
- operator address: ${operator_address}
- chain id: ${chain_id}
- provider name: ${provider_name}
- delegation contract placeholder: ${delegation_contract}

This proves the BON validator-track transaction sequence can be assembled locally.
Actual completion still requires a live network, a funded operator wallet, and the real delegation contract address returned after provider creation.
EOF
