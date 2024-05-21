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

    function testBeforeAoriTrade_failInvalidTrade() public {
        IAoriV2.MatchingDetails memory matching;

        vm.startPrank(FAKE_MAKER_WALLET);
        vm.expectRevert("Invalid trade");
        aoriPool.beforeAoriTrade(matching, "0x3");
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                             AFTERAORITRADE
    //////////////////////////////////////////////////////////////*/

    function testAfterAoriTrade_failInvalidOrder() public {
        IAoriV2.MatchingDetails memory matching;

        vm.startPrank(FAKE_MAKER_WALLET);
        vm.expectRevert("Invalid trade");
        aoriPool.afterAoriTrade(matching, "0x3");
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                                  HOOK
    //////////////////////////////////////////////////////////////*/

    function testHook_success() public {
        IAoriV2.Order memory makerOrder = IAoriV2.Order({
            offerer: MAKER_WALLET,
            inputToken: address(tokenA),
            inputAmount: 1,
            inputChainId: 1,
            inputZone: address(aoriProtocol),
            outputToken: address(tokenB),
            outputAmount: 1,
            outputChainId: 1,
            outputZone: address(aoriProtocol),
            startTime: block.timestamp - 10,
            endTime: block.timestamp + 10,
            salt: 0,
            counter: 0,
            toWithdraw: false
        });

        (uint8 makerV, bytes32 makerR, bytes32 makerS) = vm.sign(
            MAKER_PRIVATE_KEY,
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    aoriProtocol.getOrderHash(makerOrder)
                )
            )
        );

        IAoriV2.Order memory takerOrder = IAoriV2.Order({
            offerer: TAKER_WALLET,
            inputToken: address(tokenB),
            inputAmount: 1,
            inputChainId: 1,
            inputZone: address(aoriProtocol),
            outputToken: address(tokenA),
            outputAmount: 1,
            outputChainId: 1,
            outputZone: address(aoriProtocol),
            startTime: block.timestamp - 10,
            endTime: block.timestamp + 10,
            salt: 0,
            counter: 0,
            toWithdraw: false
        });

        (uint8 takerV, bytes32 takerR, bytes32 takerS) = vm.sign(
            TAKER_PRIVATE_KEY,
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    aoriProtocol.getOrderHash(takerOrder)
                )
            )
        );

        IAoriV2.MatchingDetails memory matching = IAoriV2.MatchingDetails({
            makerOrder: makerOrder,
            takerOrder: takerOrder,
            makerSignature: abi.encodePacked(makerR, makerS, makerV),
            takerSignature: abi.encodePacked(takerR, takerS, takerV),
            blockDeadline: block.number + 100,
            seatNumber: 0,
            seatHolder: address(SERVER_WALLET),
            seatPercentOfFees: 0
        });

        (uint8 serverV, bytes32 serverR, bytes32 serverS) = vm.sign(
            SERVER_PRIVATE_KEY,
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    aoriProtocol.getMatchingHash(matching)
                )
            )
        );

        vm.startPrank(TAKER_WALLET);
        tokenA.mint(1 ether);
        tokenA.approve(address(aoriProtocol), 1 ether);
        vm.stopPrank();

        vm.startPrank(TAKER_WALLET);
        tokenB.mint(1 ether);
        tokenB.approve(address(aoriProtocol), 1 ether);
        vm.stopPrank();

        vm.startPrank(MAKER_WALLET, MAKER_WALLET);
        aoriProtocol.settleOrders(
            matching,
            abi.encodePacked(serverR, serverS, serverV),
            abi.encode(preSwapInstructions, postSwapInstructions),
            "");
        vm.stopPrank();
    }
}