#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This installer must run on Ubuntu/Linux." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
home_dir="${HOME}"
scripts_dir="${home_dir}/mx-chain-scripts"
node_zip="${BON_NODE_KEY_ZIP:-}"
validator_pem="${BON_VALIDATOR_PEM:-}"
temp_dir=""

cleanup() {
  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir"
  fi
}
trap cleanup EXIT

if [[ -z "$node_zip" && -z "$validator_pem" ]]; then
  cat >&2 <<EOF
Provide one of:
- BON_NODE_KEY_ZIP=/absolute/path/to/node-0.zip
- BON_VALIDATOR_PEM=/absolute/path/to/validatorKey.pem

This script no longer uses a bundled key archive by default.
EOF
  exit 1
fi

if [[ -n "$validator_pem" ]]; then
  if [[ ! -f "$validator_pem" ]]; then
    echo "Validator PEM not found: $validator_pem" >&2
    exit 1
  fi
  if ! command -v zip >/dev/null 2>&1; then
    echo "zip is required when BON_VALIDATOR_PEM is used." >&2
    exit 1
  fi
  temp_dir="$(mktemp -d)"
  cp "$validator_pem" "${temp_dir}/validatorKey.pem"
  (
    cd "$temp_dir"
    zip -q node-0.zip validatorKey.pem
  )
  node_zip="${temp_dir}/node-0.zip"
fi

if [[ ! -f "$node_zip" ]]; then
  echo "Node key bundle not found: $node_zip" >&2
  exit 1
fi

if [[ ! -d "$scripts_dir" ]]; then
  git clone https://github.com/multiversx/mx-chain-scripts "$scripts_dir"
fi

cd "$scripts_dir"

perl -0pi -e 's/ENVIRONMENT=".*?"/ENVIRONMENT="mainnet"/' config/variables.cfg
perl -0pi -e 's#CUSTOM_HOME=".*?"#CUSTOM_HOME="'"$home_dir"'"#' config/variables.cfg
perl -0pi -e 's/CUSTOM_USER=".*?"/CUSTOM_USER="'"$(id -un)"'"/' config/variables.cfg
perl -0pi -e 's/NODE_EXTRA_FLAGS=".*?"/NODE_EXTRA_FLAGS="-log-save"/' config/variables.cfg
perl -0pi -e 's/OVERRIDE_CONFIGVER=".*?"/OVERRIDE_CONFIGVER="v1.11.0.3-bon"/' config/variables.cfg

mkdir -p "${home_dir}/VALIDATOR_KEYS"
cp "$node_zip" "${home_dir}/VALIDATOR_KEYS/node-0.zip"

# The official installer prompts for:
# 1) number of nodes
# 2) custom node name
printf '1\nValidatorBoN\n' | ./script.sh install

cat <<EOF
BoN node install completed.

Next commands:
cd ${scripts_dir}
./script.sh start_all

Verification:
${script_dir}/verify-bon-node.sh
EOF
