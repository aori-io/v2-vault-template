// MINT YIN YANG
// APPROVE TOKENS FOR AORI_PROTOCOL

pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import "../contracts/AoriVault.sol";
import {IAoriVault} from "../contracts/interfaces/IAoriVault.sol";
import {Instruction} from "../contracts/interfaces/IBatchExecutor.sol";
import {ICREATE3Factory} from "create3-factory/src/ICREATE3Factory.sol";

interface Mintable {
    function mint(uint256 amount) external;
}

contract SetupScript is Script {

    Instruction[] internal instructions;

    function run() external {
        mintAndApproveTokensOn("goerli");
        mintAndApproveTokensOn("arbitrum-sepolia");
        mintAndApproveTokensOn("sepolia");
    }

    function mintAndApproveTokensOn(string memory network) internal {

        uint256 ownerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address ownerAddress = vm.addr(ownerPrivateKey);
        string memory AORI_VAULT_VERSION = "Aori Vault v2.0";

        address AORI_PROTOCOL = vm.envAddress("AORIPROTOCOL_ADDRESS");
        address yinToken = vm.envAddress("YIN_ADDRESS");
        address yangToken = vm.envAddress("YANG_ADDRESS");

        vm.createSelectFork(network);
        address create3FactoryAddress = vm.envAddress("CREATE3FACTORY_ADDRESS");
        address aoriVaultContract = ICREATE3Factory(create3FactoryAddress).getDeployed(
            ownerAddress,
            keccak256(bytes(AORI_VAULT_VERSION))
        );

        // Make sure that the yin token exists
        if (yinToken.code.length != 0) {

            // Mint the yin token
            instructions.push(Instruction({
                to: yinToken,
                value: 0,
                data: abi.encodeCall(Mintable.mint, 1_000_000 ether)
            }));

            // Approve the yin token
            instructions.push(Instruction({
                to: yinToken,
                value: 0,
                data: abi.encodeCall(IERC20.approve, (vm.envAddress("AORIPROTOCOL_ADDRESS"), 100000 ether))
            }));
        }

        // Make sure that the yang token exists
        if (yangToken.code.length != 0) {

            // Mint the yang token
            instructions.push(Instruction({
                to: yangToken,
                value: 0,
                data: abi.encodeCall(Mintable.mint, 1_000_000 ether)
            }));

            // Approve the yang token
            instructions.push(Instruction({
                to: yangToken,
                value: 0,
                data: abi.encodeCall(IERC20.approve, (vm.envAddress("AORIPROTOCOL_ADDRESS"), 100000 ether))
            }));
        }

        vm.startBroadcast(ownerPrivateKey);
        IAoriVault(aoriVaultContract).execute(instructions);
        vm.stopBroadcast();
        
        // Empty instructions
        for (uint256 i = 0; i < instructions.length; i++) {
            instructions.pop();
        }
    }
}