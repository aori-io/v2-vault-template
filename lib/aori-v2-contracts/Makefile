tests:
	forge test --fork-url https://rpc.ankr.com/eth_goerli --via-ir -vvv
gas-report:
	forge test --fork-url https://rpc.ankr.com/eth_goerli --via-ir --gas-report
test-deploy-goerli:
	forge script script/Deploy.s.sol:DeployScript --fork-url https://rpc.ankr.com/eth_goerli --via-ir --broadcast