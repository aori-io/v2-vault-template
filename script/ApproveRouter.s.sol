// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IAoriVault} from "../contracts/interfaces/IAoriVault.sol";
import {Instruction} from "../contracts/interfaces/IBatchExecutor.sol";

contract ApproveRouterScript is Script {

    Instruction[] internal instructions;

    function run() external {
        uint256 ownerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        address ownerAddress = vm.addr(ownerPrivateKey);
        address aoriVaultContract = vm.envAddress("VAULT_ADDRESS");
        address routerAddress = vm.envAddress("ROUTER_ADDRESS");

        /*//////////////////////////////////////////////////////////////
                                ARBITRUM TOKENS
        //////////////////////////////////////////////////////////////*/
        
        instructions.push(Instruction({
            to: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6, // WETH
            value: 0,
            data: abi.encodeCall(IERC20.approve, (0xE592427A0AEce92De3Edee1F18E0157C05861564, 100000 ether))
        }));

        // instructions.push(Instruction({
        //     to: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831, // USDC
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8, // USDC.e
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, // USDT
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0xf97f4df75117a78c1A5a0DBb814Af92458539FB4, // LINK
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f, // WBTC
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, // DAI
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0, // UNI
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0x4D15a3A2286D883AF0AA1B3f21367843FAc63E07, // TUSD
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0x13Ad51ed4F1B7e9Dc168d8a00cB3f4dDD85EfA60, // LDO
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0x912CE59144191C1204E64559FE8253a0e49E6548, // ARB
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        // instructions.push(Instruction({
        //     to: 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978, // CRV
        //     value: 0,
        //     data: abi.encodeCall(IERC20.approve, (routerAddress, 100000 ether))
        // }));

        vm.startBroadcast(ownerPrivateKey);
        IAoriVault(aoriVaultContract).execute(instructions);
        vm.stopBroadcast();
    }
}