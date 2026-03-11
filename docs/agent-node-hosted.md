# Hosted Node Path

Use this path when the operator has a real Ubuntu server and wants the official `mx-chain-scripts` flow.

## When To Use It

Use the hosted path when:

- the goal is a durable node
- the agent has SSH access to Ubuntu
- the operator wants the official scripts rather than a local native build

## Minimum Host

Recommended floor:

- Ubuntu 22.04 or newer
- `4 vCPU`
- `16 GB RAM`
- `250 GB` SSD

Reference: [machine-checklist.md](machine-checklist.md)

## Required Config

In `mx-chain-scripts/config/variables.cfg` set:

```bash
ENVIRONMENT="mainnet"
OVERRIDE_CONFIGVER="v1.11.0.3-bon"
NODE_EXTRA_FLAGS="-log-save"
```

## Key Path Decision

Fresh validator:

- use `validatorKey.pem`
- package it as `node-0.zip` if using the normal scripts installer flow
- set `RedundancyLevel = 0`

Existing mainnet validator:

- use the multikey PEM
- the filename may appear as `allValidatorsKey.pem` or `allValidatorsKeys.pem` depending on the tool and script path
- set `RedundancyLevel = 1` if BoN explicitly requires it for the imported-key phase
- later switch back to `0` if the BoN organizers instruct that change

## Fastest Hosted Path In This Workspace

This workspace already contains a BoN installer helper:

- [node-challenge/install-bon-node.sh](../node-challenge/install-bon-node.sh)
- [node-challenge/verify-bon-node.sh](../node-challenge/verify-bon-node.sh)

Do not reuse someone else's `node-0.zip`. Generate your own bundle from your own validator key or let the helper script build it from `BON_VALIDATOR_PEM`.

## Official Install Sequence

On the Ubuntu host:

```bash
git clone https://github.com/multiversx/mx-chain-scripts
cd mx-chain-scripts
```

Edit `config/variables.cfg` with the BoN values above.

Then run the installer and start the node:

```bash
./script.sh install
./script.sh start_all
```

If the helper script in this workspace is available, it automates the BoN-specific edits:

```bash
chmod +x install-bon-node.sh verify-bon-node.sh
BON_VALIDATOR_PEM=/absolute/path/validatorKey.pem ./install-bon-node.sh
cd ~/mx-chain-scripts
./script.sh start_all
```

## Name The Node

The running node name must contain `BoN`.

If the scripts installer prompts for a custom node name, use a value such as:

- `ValidatorBoN`
- `YourBrandBoN`

If the name must be patched after install, set it in the node `prefs.toml` under:

```toml
NodeDisplayName = "YourNodeBoN"
```

## Verification

Keep these checks:

```bash
systemctl status elrond-node-0 --no-pager
curl -s http://127.0.0.1:8080/node/status
curl -s http://127.0.0.1:8080/node/heartbeatstatus
```

And inspect logs for:

- `v1.11.0.3-bon`
- `trie sync in progress`
- later block processing after trie sync

The helper verifier in this workspace does exactly that:

- [node-challenge/verify-bon-node.sh](../node-challenge/verify-bon-node.sh)
