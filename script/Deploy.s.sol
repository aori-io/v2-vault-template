// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { ICREATE3Factory } from "create3-factory/src/ICREATE3Factory.sol";
import { MultichainDeployScript } from "./MultichainDeploy.s.sol";
import "../contracts/AoriVault.sol";

contract DeployScript is Script, MultichainDeployScript {
    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address deployerAddress = vm.addr(deployerPrivateKey);
        address aoriProtocolAddress = vm.envAddress("AORIPROTOCOL_ADDRESS");
        bytes memory bytecode = abi.encodePacked(type(AoriVault).creationCode, abi.encode(deployerAddress, aoriProtocolAddress));

        string memory AORI_VAULT_VERSION = "Aori Vault v2.0";

        /*//////////////////////////////////////////////////////////////
                                    TESTNETS
        //////////////////////////////////////////////////////////////*/

        deployTo("goerli", AORI_VAULT_VERSION, bytecode);
        deployTo("sepolia", AORI_VAULT_VERSION, bytecode);
        deployTo("arbitrum-sepolia", AORI_VAULT_VERSION, bytecode);

        /*//////////////////////////////////////////////////////////////
                                    MAINNETS
        //////////////////////////////////////////////////////////////*/

    }
}
