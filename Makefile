build:
	forge build --via-ir
tests:
	forge test --fork-url https://rpc.ankr.com/eth --via-ir -vvv
deploy:
	forge script script/Deploy.s.sol:DeployScript --via-ir --legacy --broadcast
setup:
	forge script script/Setup.s.sol:SetupScript --via-ir --legacy --broadcast
approve-router:
	forge script script/ApproveRouter.s.sol:ApproveRouterScript --fork-url https://arb1.arbitrum.io/rpc --via-ir --legacy --broadcast