// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import { ICREATE3Factory } from "create3-factory/src/ICREATE3Factory.sol";
import { MultichainDeployScript } from "../MultichainDeploy.s.sol";
import "../../contracts/AoriPool.sol";

contract DeployPoolScript is Script, MultichainDeployScript {
    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address deployerAddress = vm.addr(deployerPrivateKey);
        address aoriProtocolAddress = vm.envAddress("AORIPROTOCOL_ADDRESS");
        address baseToken = vm.envAddress("POOL_BASE_TOKEN");
        address quoteToken = vm.envAddress("POOL_QUOTE_TOKEN");

        bytes memory bytecode = abi.encodePacked(
            type(AoriPool).creationCode,
            abi.encode(
                deployerAddress,
                aoriProtocolAddress,
                baseToken,
                quoteToken
            )
        );

        string memory AORI_POOL_VERSION = 
            string(abi.encode(
                "Aori Pool v2.0 - ",
                baseToken,
                "/",
                quoteToken
            ));

        /*//////////////////////////////////////////////////////////////
                                    TESTNETS
        //////////////////////////////////////////////////////////////*/

        // deployTo("sepolia", AORI_VAULT_VERSION, bytecode);
        deployTo("arbitrum", AORI_POOL_VERSION, bytecode);

        /*//////////////////////////////////////////////////////////////
                                    MAINNETS
        //////////////////////////////////////////////////////////////*/

    }
}
