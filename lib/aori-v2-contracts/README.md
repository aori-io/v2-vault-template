# Aori V2 Smart Contract

A template for quickly getting started with forge

## Getting Started

```
git clone https://github.com/aori-io/aori-v2-contracts
git submodule update --init --recursive  ## initialize submodule dependencies
forge build
make tests ## run tests
```

### Verification

```
forge verify-contract 0x8558eCbA75DB19df2Fb1B70fe8661D296F68dFE7 src/AoriV2.sol:AoriV2 --optimizer-runs 1000000 --show-standard-json-input > single-chain-aori-v2-etherscan.json
```

### CI with Github Actions

Automatically run linting and tests on pull requests.
## Acknowledgement

Inspired by great dapptools templates like https://github.com/gakonst/forge-template, https://github.com/gakonst/dapptools-template and https://github.com/transmissions11/dapptools-template
