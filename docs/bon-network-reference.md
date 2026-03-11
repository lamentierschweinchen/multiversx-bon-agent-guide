# BoN Network Reference

This file captures the BoN-specific values and challenge rules that an agent needs before touching any commands.

## Canonical Network Values

- Chain ID: `B`
- Proxy / API base: `https://api.battleofnodes.com`
- `mx-chain-scripts` variables:
  - `ENVIRONMENT="mainnet"`
  - `OVERRIDE_CONFIGVER="v1.11.0.3-bon"`
  - `NODE_EXTRA_FLAGS="-log-save"`

## Naming Rules

- Staking provider name must contain `BoN`.
- Validator node display name must contain `BoN`.
- Recommended pattern: suffix `BoN`.

Examples:

- `MyProviderBoN`
- `Validator01BoN`
- `BerlinNodeBoN`

## Validator Track Tasks

1. Create a staking provider.
2. Set metadata with a name containing `BoN`.
3. Add the node to the staking provider.
4. Ensure the provider reaches at least `2500 EGLD`.
5. Stake the node so it becomes a validator.

## Node Challenge Rules

BoN says they will verify that:

1. the node is started and synced to the BoN state
2. the heartbeat reports the BoN version
3. the provider name contains `BoN`
4. all registered nodes contain `BoN` in their name

For local proof gathering, keep:

- transaction JSON outputs
- transaction hashes
- node logs
- `heartbeatstatus` output
- `status` output

## BoN Fork / Bootstrap Notes

The BoN network was described as a mainnet shadowfork with these operator-facing differences:

- bootstrapped from mainnet data
- chain ID changed from `"1"` to `"B"`
- validators should use the BoN-specific config override
- infrastructure providers may use the published database snapshots

The user-provided BoN infrastructure note gave these bootstrap points:

- snapshot source point:
  - round `29042710`
  - epoch `2016`
  - timestamp `1770373860`
- published running DB snapshots:
  - round `29505662`
  - epoch `2030`
  - timestamp `2026-03-10 14:03:00 UTC`

## Snapshot URLs

These are the published snapshot URLs from the BoN infrastructure note:

- metachain:
  - [SF-BON-running-DB-Round-29505662-Shard-metachain.tar.gz](https://shadowfork-running-archives.fra1.digitaloceanspaces.com/shadowfork-bon/10-Mar-2026-14-03/SF-BON-running-DB-Round-29505662-Shard-metachain.tar.gz)
- shard 0:
  - [SF-BON-running-DB-Round-29505662-Shard-0.tar.gz](https://shadowfork-running-archives.fra1.digitaloceanspaces.com/shadowfork-bon/10-Mar-2026-14-03/SF-BON-running-DB-Round-29505662-Shard-0.tar.gz)
- shard 1:
  - [SF-BON-running-DB-Round-29505662-Shard-1.tar.gz](https://shadowfork-running-archives.fra1.digitaloceanspaces.com/shadowfork-bon/10-Mar-2026-14-03/SF-BON-running-DB-Round-29505662-Shard-1.tar.gz)
- shard 2:
  - [SF-BON-running-DB-Round-29505662-Shard-2.tar.gz](https://shadowfork-running-archives.fra1.digitaloceanspaces.com/shadowfork-bon/10-Mar-2026-14-03/SF-BON-running-DB-Round-29505662-Shard-2.tar.gz)

Use snapshots only if the operator wants to shorten sync time. A fresh node can still bootstrap from the network and show `trie sync in progress`.

## Existing Mainnet Validators

If the operator is reusing existing mainnet validator keys, the BoN note says:

- use `allValidatorsKey.pem`
- set `RedundancyLevel = 1`
- later, after organizer key rotation / cleanup, restart with `RedundancyLevel = 0`

Practical file-name note:

- the challenge text referred to `allValidatorsKey.pem`
- some runtime paths and node flags use `allValidatorsKeys.pem`
- use the filename expected by the install method you chose, but treat them as the same multikey concept

For a fresh validator path, use a single `validatorKey.pem` and `RedundancyLevel = 0`.
