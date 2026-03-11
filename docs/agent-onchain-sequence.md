# On-Chain Sequence

This is the exact agent-friendly `mxpy` sequence for the initial BoN validator setup.

It assumes the operator already has:

- an operator wallet PEM
- a validator PEM
- enough funds in the operator wallet

## Required Variables

Set these first:

```bash
PROXY="https://api.battleofnodes.com"
CHAIN="B"

OPERATOR_PEM="/absolute/path/operator-wallet.pem"
VALIDATOR_PEM="/absolute/path/validatorKey.pem"

PROVIDER_NAME="YourProviderBoN"
PROVIDER_WEBSITE="https://example.com"
PROVIDER_IDENTIFIER="your-github-handle"
```

## Optional Preflight

Get the operator address:

```bash
mxpy wallet convert \
  --infile "$OPERATOR_PEM" \
  --in-format pem \
  --out-format address-bech32
```

Extract the BLS public key:

```bash
./scripts/extract-bls-pubkey.sh "$VALIDATOR_PEM"
```

## 1. Create The Staking Provider

Important BoN note:

- the proven working `--value` form was atomic units
- the proven working creation value was `1252000000000000000000`
- `--total-delegation-cap` remained in whole EGLD units

```bash
mxpy staking-provider create-new-delegation-contract \
  --proxy "$PROXY" \
  --pem "$OPERATOR_PEM" \
  --chain "$CHAIN" \
  --value 1252000000000000000000 \
  --total-delegation-cap 2500 \
  --service-fee 1000 \
  --send \
  --outfile create-provider-live.json
```

Extract the transaction hash:

```bash
CREATE_HASH="$(sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' create-provider-live.json)"
echo "$CREATE_HASH"
```

Resolve the delegation contract address:

```bash
DELEGATION_CONTRACT="$(
  mxpy staking-provider get-contract-address \
    --proxy "$PROXY" \
    --create-tx-hash "$CREATE_HASH" | awk '/Delegation contract address:/ {print $4}'
)"
echo "$DELEGATION_CONTRACT"
```

If the proxy times out while resolving the contract address, retry the same command after the creation transaction is fully processed.

## 2. Set Provider Metadata

The provider name must contain `BoN`.

```bash
mxpy staking-provider set-metadata \
  --proxy "$PROXY" \
  --pem "$OPERATOR_PEM" \
  --chain "$CHAIN" \
  --delegation-contract "$DELEGATION_CONTRACT" \
  --name "$PROVIDER_NAME" \
  --website "$PROVIDER_WEBSITE" \
  --identifier "$PROVIDER_IDENTIFIER" \
  --send \
  --outfile set-metadata-live.json
```

## 3. Top Up The Provider To 2500 EGLD

The proven working top-up value was `1248000000000000000000`.

```bash
mxpy staking-provider delegate \
  --proxy "$PROXY" \
  --pem "$OPERATOR_PEM" \
  --chain "$CHAIN" \
  --delegation-contract "$DELEGATION_CONTRACT" \
  --value 1248000000000000000000 \
  --send \
  --outfile delegate-topup-live.json
```

## 4. Add The Node

`mxpy` derives the node signature directly from the validator PEM.

```bash
mxpy staking-provider add-nodes \
  --proxy "$PROXY" \
  --pem "$OPERATOR_PEM" \
  --validators-pem "$VALIDATOR_PEM" \
  --chain "$CHAIN" \
  --delegation-contract "$DELEGATION_CONTRACT" \
  --send \
  --outfile add-nodes-live.json
```

## 5. Stake The Node

```bash
mxpy staking-provider stake-nodes \
  --proxy "$PROXY" \
  --pem "$OPERATOR_PEM" \
  --validators-pem "$VALIDATOR_PEM" \
  --chain "$CHAIN" \
  --delegation-contract "$DELEGATION_CONTRACT" \
  --send \
  --outfile stake-nodes-live.json
```

## 6. Immediate Verification

Inspect the emitted transaction hashes:

```bash
for f in create-provider-live.json set-metadata-live.json delegate-topup-live.json add-nodes-live.json stake-nodes-live.json; do
  echo "FILE:$f"
  sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' "$f"
done
```

Check each transaction:

```bash
for h in \
  "$(sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' create-provider-live.json)" \
  "$(sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' set-metadata-live.json)" \
  "$(sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' delegate-topup-live.json)" \
  "$(sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' add-nodes-live.json)" \
  "$(sed -En 's/^[[:space:]]*\"emittedTransactionHash\":[[:space:]]*\"([0-9a-f]+)\".*/\\1/p' stake-nodes-live.json)"; do
  echo "HASH:$h"
  curl -sS "$PROXY/transactions/$h?withResults=true"
  echo
done
```

## Fallback

If the agent should only build payloads and not send them yet, use:

- [../scripts/build-provider-txs.sh](../scripts/build-provider-txs.sh)
- [../scripts/build-add-node-tx.sh](../scripts/build-add-node-tx.sh)
