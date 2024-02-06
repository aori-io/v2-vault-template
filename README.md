# Aori V2 Vaults Template

![.](assets/aori-vault-template.svg)

This boilerplate is a simple smart contract vault template that can be used to store and manage assets programmatically.

An executor wallet must be provided in order to execute `Instruction`s against the vault, but managers can be added to sign off on signature requests.

## Deployments

Below is a list of example deployments used by the Aori team to help bootstrap liquidity through DEX aggregators.

Deployed and executed by `0xD2e31e651C5EdD8743355A9B29AeFb993880d14C`:

| Network | Address |
|---------|---------|
| `Goerli (5)` | [0x11530084405184b1BE7CAd29c9fa0626bcDBe6A3](https://goerli.etherscan.io/address/0x11530084405184b1BE7CAd29c9fa0626bcDBe6A3) |
| `Arbitrum (42161)` | [0x11530084405184b1BE7CAd29c9fa0626bcDBe6A3](https://arbiscan.io/address/0x11530084405184b1BE7CAd29c9fa0626bcDBe6A3) |

## Usage

To run the tests, run:
```
make tests
```

## Etherscan Verification
```
forge verify-contract 0x3CaF656457EC1f09b8BEc3B8dB2dF2A927Cf8106 contracts/AoriVault.sol:AoriVault --optimizer-runs 1000000 --show-standard-json-input > etherscan/aori-vault.json 
```