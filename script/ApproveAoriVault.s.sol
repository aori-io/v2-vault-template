// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IAoriVault} from "../contracts/interfaces/IAoriVault.sol";
import {Instruction} from "../contracts/interfaces/IBatchExecutor.sol";

interface ISimpleToken {
    function mint(uint256 amount) external;
}

contract ApproveAoriVaultScript is Script {

    Instruction[] internal instructions;

    function run() external {
        uint256 ownerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address ownerAddress = vm.addr(ownerPrivateKey);
        address aoriVaultContract = vm.envAddress("VAULT_ADDRESS");
        address aoriZoneContract = vm.envAddress("AORIPROTOCOL_ADDRESS");

        /*//////////////////////////////////////////////////////////////
                                ARBITRUM TOKENS
        //////////////////////////////////////////////////////////////*/
        
        instructions.push(Instruction({
            to: 0x62FA33af921f620f9D04E9664b06807bB3BAD57B,
            value: 0,
            data: abi.encodeCall(ISimpleToken.mint, (99 ether))
        }));

        instructions.push(Instruction({
            to: 0xbEfDe6cCa7C2BF6a57Bdc2BB41567577c8935EDe,
            value: 0,
            data: abi.encodeCall(ISimpleToken.mint, (99 ether))
        }));

        instructions.push(Instruction({
            to: 0x62FA33af921f620f9D04E9664b06807bB3BAD57B, // YIN
            value: 0,
            data: abi.encodeCall(IERC20.approve, (aoriZoneContract, 100000 ether))
        }));

        instructions.push(Instruction({
            to: 0xbEfDe6cCa7C2BF6a57Bdc2BB41567577c8935EDe, // YANG
            value: 0,
            data: abi.encodeCall(IERC20.approve, (aoriZoneContract, 100000 ether))
        }));

        
        vm.startBroadcast(ownerPrivateKey);
        IAoriVault(aoriVaultContract).execute(instructions);
        vm.stopBroadcast();
    }
}