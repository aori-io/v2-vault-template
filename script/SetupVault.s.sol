// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import "../contracts/AoriVault.sol";
import {IAoriVault} from "../contracts/interfaces/IAoriVault.sol";
import {Instruction} from "../contracts/interfaces/IBatchExecutor.sol";
import {ICREATE3Factory} from "create3-factory/src/ICREATE3Factory.sol";

contract SetupVaultScript is Script {

    Instruction[] internal instructions;

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address deployerAddress = vm.addr(deployerPrivateKey);
        address create3FactoryAddress = vm.envAddress("CREATE3FACTORY_ADDRESS");
        address aoriProtocolAddress = vm.envAddress("AORIPROTOCOL_ADDRESS");
        bytes32 salt = keccak256("an aori vault template - alpha-5");

        /*//////////////////////////////////////////////////////////////
                                    APPROVE
        //////////////////////////////////////////////////////////////*/

        instructions.push(Instruction({
            to: 0x62FA33af921f620f9D04E9664b06807bB3BAD57B, // YIN
            value: 0,
            data: abi.encodeCall(IERC20.approve, (aoriProtocolAddress, 100000 ether))
        }));

        instructions.push(Instruction({
            to: 0xbEfDe6cCa7C2BF6a57Bdc2BB41567577c8935EDe, // YANG
            value: 0,
            data: abi.encodeCall(IERC20.approve, (aoriProtocolAddress, 100000 ether))
        }));

        vm.startBroadcast(deployerPrivateKey);

        /*//////////////////////////////////////////////////////////////
                                     DEPLOY
        //////////////////////////////////////////////////////////////*/

        // Deploy Vault
        ICREATE3Factory(create3FactoryAddress).deploy(
            salt,
            abi.encodePacked(
                type(AoriVault).creationCode,
                abi.encode(deployerAddress, aoriProtocolAddress)
            )
        );

        // Get Deployed Vault Address
        address aoriVaultContract = ICREATE3Factory(create3FactoryAddress)
            .getDeployed(deployerAddress, salt);

        // Approve Tokens for the Aori Vault Contract to the Aori Protocol
        IAoriVault(aoriVaultContract).execute(instructions);

        vm.stopBroadcast();
    }
}
