# Verification Checklist

Use this checklist after the agent finishes the initial setup.

## On-Chain Proof

The following must be true:

1. provider creation transaction succeeded
2. provider metadata transaction succeeded
3. provider name contains `BoN`
4. add-nodes transaction succeeded
5. delegate top-up transaction succeeded
6. provider stake reached at least `2500 EGLD`
7. stake-nodes transaction succeeded

## Required Artifacts

Keep:

1. transaction hashes
2. signed JSON outputs or command outputs
3. the resolved delegation contract address
4. the BLS public key

Useful checks:

- `mxpy staking-provider get-contract-address --proxy https://api.battleofnodes.com --create-tx-hash <HASH>`
- `curl -sS https://api.battleofnodes.com/transactions/<HASH>?withResults=true`
- `curl -sS https://api.battleofnodes.com/accounts/<BECH32>`

## Node Proof

The following must be true:

1. the node process or systemd service is running
2. the node display name contains `BoN`
3. logs show the BoN version string
4. logs show `trie sync in progress`
5. the node later exits bootstrap and serves heartbeat/status normally

## Local API Checks

```bash
curl -sS -i http://127.0.0.1:8080/node/status
curl -sS -i http://127.0.0.1:8080/node/heartbeatstatus
```

Interpretation:

- `{"error":"node is starting"}` means bootstrap is still in progress
- a structured JSON response means the node API is ready

## Common Failure Modes

1. Wrong amount units on `create-new-delegation-contract`
   - On BoN, the proven working `--value` form was atomic units, not plain `1250`

2. Correct provider, wrong node name
   - provider metadata does not set the running node display name
   - `NodeDisplayName` or `--display-name` must also contain `BoN`

3. Waiting forever for final proof
   - the node may be healthy but still bootstrapping
   - logs with `trie sync in progress` are good
   - use a snapshot if time matters

4. Manual BLS-signature dead end
   - do not generate the `addNodes` signature by hand if `mxpy` can do it from `--validators-pem`

## Done State

The initial setup is done when:

1. the provider exists on BoN
2. the provider and node names both include `BoN`
3. the node is added and staked
4. the node is running on BoN with the BoN version
5. proof artifacts are saved
