# Battle of Nodes Public Agent Manual

This repository is a public, generic handoff for anyone who wants to complete the initial MultiversX Battle of Nodes validator setup with the help of their own agent.

It is intentionally documentation-first. It does not contain private wallets, validator keys, live transaction JSON, or user-specific node bundles.

## Start Here

- [AGENT-START-HERE.md](AGENT-START-HERE.md)

## What This Repository Covers

1. operator wallet creation or import
2. validator key creation or import
3. BoN on-chain validator setup
4. local terminal node path
5. hosted Ubuntu node path
6. verification and proof collection

## What Is Deliberately Not Included

1. any real wallet mnemonic
2. any wallet JSON keyfile
3. any wallet PEM
4. any validator PEM
5. any `node-0.zip` built from a real validator key
6. any live transaction artifacts from a specific operator

## Safe Sharing Rule

If you add local test artifacts while using this repo, do not commit them. The included [.gitignore](.gitignore) blocks the common secret and runtime file patterns, but you should still review `git status` before pushing.
