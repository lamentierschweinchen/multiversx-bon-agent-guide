# Finding values

This answers the practical question behind `.env`: where each value comes from.

## Values you can set immediately

- `NETWORK_NAME`
  - use `bon` as your local label
- `PROVIDER_NAME`
  - choose any name that ends with `BoN`, for example `YourProviderBoN`
- `PROVIDER_WEBSITE`
  - your site, X profile landing page, GitHub Pages site, or any URL you control
- `PROVIDER_GITHUB`
  - your GitHub handle or organization identifier
- `TOTAL_CAP_EGLD`
  - `2500` is the minimum meaningful value for the BON validator task
- `SERVICE_FEE_BPS`
  - your chosen service fee; `1000` means `10%`
- `CREATE_PROVIDER_EGLD`
  - `1250`
- `TOP_UP_EGLD`
  - `1250`

## Values that come from the network or previous transactions

- `DELEGATION_MANAGER_ADDRESS`
  - use the correct address for the target network
  - current docs example for the staking providers system contract:
    - `erd1qqqqqqqqqqqqqqqpqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqylllslmq6y6`
- `DELEGATION_CONTRACT_ADDRESS`
  - appears only after `createNewDelegationContract` is executed successfully
  - you can derive it from the transaction hash with `mxpy staking-provider get-contract-address`

## Values that come from your local node keys

- `VALIDATOR_KEY_PEM`
  - this is the `validatorKey.pem` file for the node you want to add
- `BLS_PUBLIC_KEY`
  - extract it from `validatorKey.pem`
  - this workspace includes `scripts/extract-bls-pubkey.sh`
- `BLS_SIGNATURE_HEX`
  - signature of the delegation contract address produced with the validator BLS private key
  - `mxpy staking-provider add-nodes --validators-pem ...` handles this automatically, so you usually do not need to compute it by hand

## Real blocker for actual BON completion

Even if every file and command is prepared locally, you still need:

- the correct BON network/proxy/chain values
- a funded operator wallet
- enough EGLD to reach `2500 EGLD`
- a live transaction hash for the provider creation

Those are external state dependencies, not engineering gaps.
