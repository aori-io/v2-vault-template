tests:
	forge test --fork-url https://rpc.ankr.com/eth --via-ir -vvv
add-new-manager:
	forge script script/AddNewManager.s.sol:AddNewManagerScript --fork-url https://rpc.ankr.com/eth_goerli --via-ir
setup-vault:
	forge script script/SetupVault.s.sol:SetupVaultScript --fork-url https://rpc.ankr.com/eth --via-ir --legacy --broadcast
approve-aori-vault:
	forge script script/ApproveAoriVault.s.sol:ApproveAoriVaultScript --fork-url https://rpc.goerli.eth.gateway.fm --via-ir --broadcast
approve-router:
	forge script script/ApproveRouter.s.sol:ApproveRouterScript --fork-url https://arbitrum.llamarpc.com --via-ir --legacy