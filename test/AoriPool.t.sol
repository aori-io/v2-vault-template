pragma solidity >=0.8.17;

import {DSTest} from "ds-test/test.sol";
import {console} from "forge-std/console.sol";
import {Vm} from "forge-std/Vm.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";

import { SimpleToken } from "./mocks/SimpleToken.sol";
import { AoriPool } from "../contracts/AoriPool.sol";
import { Instruction } from "../contracts/interfaces/IBatchExecutor.sol";
import { IAoriV2 } from "aori-v2-contracts/src/interfaces/IAoriV2.sol";
import { AoriV2 } from "aori-v2-contracts/src/AoriV2.sol";

contract AoriPoolTest is DSTest {
    Vm internal vm = Vm(HEVM_ADDRESS);
    AoriV2 internal aoriProtocol;
    AoriPool internal aoriPool;

    /*//////////////////////////////////////////////////////////////
                                 USERS
    //////////////////////////////////////////////////////////////*/
    
    uint256 SERVER_PRIVATE_KEY = 1;
    uint256 FAKE_SERVER_PRIVATE_KEY = 2;
    uint256 MAKER_PRIVATE_KEY = 3;
    uint256 FAKE_MAKER_PRIVATE_KEY = 4;
    uint256 TAKER_PRIVATE_KEY = 5;
    uint256 FAKE_TAKER_PRIVATE_KEY = 6;
    uint256 SEARCHER_PRIVATE_KEY = 7;

    address SERVER_WALLET = address(vm.addr(SERVER_PRIVATE_KEY));
    address FAKE_SERVER_WALLET = address(vm.addr(FAKE_SERVER_PRIVATE_KEY));
    address MAKER_WALLET = address(vm.addr(MAKER_PRIVATE_KEY));
    address FAKE_MAKER_WALLET = address(vm.addr(FAKE_MAKER_PRIVATE_KEY));
    address TAKER_WALLET = address(vm.addr(TAKER_PRIVATE_KEY));
    address FAKE_TAKER_WALLET = address(vm.addr(FAKE_TAKER_PRIVATE_KEY));
    address SEARCHER_WALLET = address(vm.addr(SEARCHER_PRIVATE_KEY));

    /*//////////////////////////////////////////////////////////////
                                 ASSETS
    //////////////////////////////////////////////////////////////*/

    SimpleToken tokenA = new SimpleToken();
    SimpleToken tokenB = new SimpleToken();
    SimpleToken tokenC = new SimpleToken();

    Instruction[] internal preSwapInstructions;
    Instruction[] internal postSwapInstructions;

    function setUp() public {
        aoriProtocol = new AoriV2(SERVER_WALLET);

        vm.prank(MAKER_WALLET);
        aoriPool = new AoriPool(
            MAKER_WALLET,
            address(aoriProtocol),
            address(tokenA),
            address(tokenB)
        );

        vm.label(address(aoriProtocol), "Order Protocol");
        vm.label(address(aoriPool), "Order Vault");

        vm.label(SERVER_WALLET, "Server Wallet");
        vm.label(FAKE_SERVER_WALLET, "Fake Server Wallet");
        vm.label(MAKER_WALLET, "Maker Wallet");
        vm.label(FAKE_MAKER_WALLET, "Fake Maker Wallet");
        vm.label(TAKER_WALLET, "Taker Wallet");
        vm.label(FAKE_TAKER_WALLET, "Fake Taker Wallet");

        vm.label(address(tokenA), "TokenA");
        vm.label(address(tokenB), "TokenB");

        vm.deal(MAKER_WALLET, 100 ether);
    }

    /*//////////////////////////////////////////////////////////////
                            BEFOREAORITRADE
    //////////////////////////////////////////////////////////////*/

    function testBeforeAoriTrade_failNotOwner() public {
        IAoriV2.MatchingDetails memory matching;

        vm.startPrank(FAKE_MAKER_WALLET);
        vm.expectRevert("Only a manager can force the execution of this trade");
        aoriPool.beforeAoriTrade(matching, "0x3");
        vm.stopPrank();
    }

    // TODO: 
}