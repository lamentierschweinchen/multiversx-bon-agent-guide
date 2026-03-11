#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /absolute/path/to/validatorKey.pem" >&2
  exit 1
fi

pem_path="$1"

if [[ ! -f "$pem_path" ]]; then
  echo "validator key file not found: $pem_path" >&2
  exit 1
fi

header_line="$(head -n 1 "$pem_path")"
pubkey="$(printf '%s\n' "$header_line" | sed -E 's/^-----BEGIN PRIVATE KEY for ([0-9a-fA-F]+)-----$/\1/')"

if [[ ! "$pubkey" =~ ^[0-9a-fA-F]{192}$ ]]; then
  echo "could not extract a valid 192-char BLS public key from: $pem_path" >&2
  exit 1
fi

printf '%s\n' "$pubkey" | tr 'A-F' 'a-f'
