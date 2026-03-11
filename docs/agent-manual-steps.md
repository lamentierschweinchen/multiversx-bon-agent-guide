# Minimal Manual Steps

This file defines the smallest set of tasks that normally require a human. Everything else should be automated by the agent.

## 1. Create Or Provide An Operator Wallet

Preferred path:

1. create a fresh `keystore-mnemonic` wallet
2. back up the mnemonic offline
3. convert the wallet to PEM for `mxpy`

Commands:

```bash
mxpy wallet new \
  --format keystore-mnemonic \
  --outfile "/absolute/path/operator-wallet.json"

mxpy wallet convert \
  --infile "/absolute/path/operator-wallet.json" \
  --in-format keystore-mnemonic \
  --outfile "/absolute/path/operator-wallet.pem" \
  --out-format pem
```

The agent can use either:

- `operator-wallet.pem`
- or the JSON keyfile if the agent can provide the password interactively

If the user pastes a mnemonic or password into chat, treat that wallet as burned for any future real funds.

## 2. Fund The Operator Wallet

The operator wallet must hold enough funds for:

1. provider creation
2. top-up to at least `2500 EGLD`
3. gas

The proven working BoN split in this workspace was:

- provider creation transfer: `1252 EGLD`
- top-up transfer: `1248 EGLD`

That reaches `2500 EGLD` total before gas.

## 3. Create Or Provide A Validator Key

Fresh validator:

```bash
mxpy validator-wallet new \
  --outfile "/absolute/path/validatorKey.pem"
```

Existing mainnet validator:

- provide the multikey PEM if reusing multiple keys
- the naming may appear as either `allValidatorsKey.pem` or `allValidatorsKeys.pem` depending on the tool path
- follow the BoN redundancy guidance from [bon-network-reference.md](bon-network-reference.md)

## 4. Optional: Provision A Real Hosted Server

Only needed if the goal is a durable node, not a local dry run.

Minimum practical target:

- Ubuntu 22.04 or newer
- `4 vCPU`
- `16 GB RAM`
- `250 GB` SSD

The agent needs:

- SSH host or IP
- SSH username
- local path to the SSH private key

## 5. Minimal Naming Inputs

The user should decide these once and let the agent reuse them everywhere:

- provider name: `SomethingBoN`
- node display name: `SomethingBoN`
- website URL
- identifier / GitHub handle

## 6. Hand-Off To Agent

Once the manual pieces exist, the user should only need to say:

`The wallet PEM, validator PEM, and optional server are ready. Continue from AGENT-START-HERE.md.`
