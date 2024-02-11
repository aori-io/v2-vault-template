# Aori V2 Vaults Template

![.](assets/aori-vault-template.svg)

This boilerplate is a simple smart contract vault template that can be used to store and manage assets programmatically.

An executor wallet must be provided in order to execute `Instruction`s against the vault, but managers can be added to sign off on signature requests.

## Deployments

Below is a list of example deployments used by the Aori team to help bootstrap liquidity through DEX aggregators.

Deployed and executed by `0xD2e31e651C5EdD8743355A9B29AeFb993880d14C`:

| Network | Address |
|---------|---------|
| `Mainnet (1)` | [0xd5252a54ed6269491b6adf16002e20e2ebbe5ab0](https://etherscan.io/address/0xd5252a54ed6269491b6adf16002e20e2ebbe5ab0) |
| `Goerli (5)` | [0xd5252a54ed6269491b6adf16002e20e2ebbe5ab0](https://etherscan.io/address/0xd5252a54ed6269491b6adf16002e20e2ebbe5ab0) |

## Usage

To run the tests, run:
```
make tests
```

## Etherscan Verification
```
forge verify-contract 0x3CaF656457EC1f09b8BEc3B8dB2dF2A927Cf8106 contracts/AoriVault.sol:AoriVault --optimizer-runs 1000000 --show-standard-json-input > etherscan/aori-vault.json 
```