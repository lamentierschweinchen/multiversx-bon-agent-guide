# Local Terminal Node Path

Use this path when the operator wants to prove the setup from a laptop or local terminal without provisioning Ubuntu first.

This path was proven in this workspace on macOS by building a native node and running it directly from the terminal.

## When To Use It

Use the local path when:

- the goal is to validate the workflow
- the operator wants to see a real node sync
- the agent has local shell access but no hosted server yet

Do not treat this as the final production validator environment.

## Inputs

- `validatorKey.pem`
- a display name ending with `BoN`
- enough local disk for node state
- `go`
- `git`

## Proven Local Build Plan

1. Clone the BoN config tag from `mx-chain-mainnet-config`.
2. Read `binaryVersion` from that config repo.
3. Clone `mx-chain-go` at the pinned BoN tag.
4. Build the node binary.
5. Build a runtime directory with:
   - config files from the config repo
   - `validatorKey.pem` in `config/`
   - `prefs.toml` patched with `NodeDisplayName = "<Name>BoN"`
6. Start the node with a local REST API and saved logs.
7. Wait for sync or restore a shard snapshot first.

## Proven Versions In This Workspace

- config tag: `v1.11.0.3-bon`
- config repo `binaryVersion`: `tags/v1.11.2-bon`
- config repo `goVersion`: `1.23.6`

That version mismatch is expected in BoN. The runtime still reported a BoN version string.

## Reproducible Commands

These commands assume a new working directory called `native-node`:

```bash
mkdir -p native-node
cd native-node

git clone --branch v1.11.0.3-bon https://github.com/multiversx/mx-chain-mainnet-config.git

BON_BINARY_TAG="$(sed 's#tags/##' mx-chain-mainnet-config/binaryVersion)"

git clone --branch "$BON_BINARY_TAG" https://github.com/multiversx/mx-chain-go.git

WORKDIR="$(pwd)"
mkdir -p "$WORKDIR/runtime/node-0/config" "$WORKDIR/runtime/node-0/logs" /tmp/go-build-bon /tmp/go-mod-bon

cp -R "$WORKDIR/mx-chain-mainnet-config/"* "$WORKDIR/runtime/node-0/config/"
cp "/absolute/path/validatorKey.pem" "$WORKDIR/runtime/node-0/config/validatorKey.pem"

cd "$WORKDIR/mx-chain-go/cmd/node"
GOCACHE=/tmp/go-build-bon GOMODCACHE=/tmp/go-mod-bon go build \
  -o "$WORKDIR/runtime/node-0/node" \
  -ldflags="-X main.appVersion=$(git --git-dir "$WORKDIR/mx-chain-mainnet-config/.git" describe --tags --long --dirty)"
```

Then patch the runtime config:

```bash
perl -0pi -e 's/NodeDisplayName = \".*?\"/NodeDisplayName = \"YourNodeBoN\"/' "$WORKDIR/runtime/node-0/config/prefs.toml"
perl -0pi -e 's/RedundancyLevel = .*/RedundancyLevel = 0/' "$WORKDIR/runtime/node-0/config/prefs.toml"
```

## Runtime Layout

Create a `node-0` runtime directory with this minimum structure:

- `node-0/node`
- `node-0/config/*` from `mx-chain-mainnet-config`
- `node-0/config/validatorKey.pem`
- `node-0/logs/`

Patch `node-0/config/prefs.toml`:

```toml
NodeDisplayName = "YourNodeBoN"
RedundancyLevel = 0
```

## Start Command

This is the start shape that was proven in this workspace:

```bash
./node \
  -use-log-view \
  -log-logger-name \
  -log-correlation \
  -log-level '*:DEBUG' \
  -rest-api-interface localhost:8080 \
  --display-name YourNodeBoN \
  --log-save \
  --port 41000
```

Run it from the runtime directory that contains `./node` and `./config`.

## What Success Looks Like

Early success signals:

1. the process stays up
2. logs show the BoN version string
3. logs show peer connections
4. logs show `trie sync in progress`

Later success signals:

1. `/node/status` stops returning `node is starting`
2. `/node/heartbeatstatus` returns real heartbeat data
3. the node processes blocks after trie sync

## Snapshot Option

If full trie sync is too slow, use the published BoN shard snapshot from [bon-network-reference.md](bon-network-reference.md).

Practical rule:

1. start once without a snapshot
2. determine the assigned shard from logs or session info
3. restore the matching shard snapshot
4. restart

## Reference Rule

This public repository does not ship a built runtime directory. The agent should create its own `native-node/runtime/node-0` tree using the steps above and the official repos linked in [agent-official-resources.md](agent-official-resources.md).
