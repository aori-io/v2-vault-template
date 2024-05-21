// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import { IAoriVault } from "./interfaces/IAoriVault.sol";
import { IAoriV2 } from "aori-v2-contracts/src/interfaces/IAoriV2.sol";
import { Instruction } from "./interfaces/IBatchExecutor.sol";
import { BatchExecutor } from "./BatchExecutor.sol";

contract AoriVault is IAoriVault, BatchExecutor {

    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;
    
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    address public aoriProtocol;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _owner,
        address _aoriProtocol
    ) BatchExecutor(_owner) {
        aoriProtocol = _aoriProtocol;
    }

    /*//////////////////////////////////////////////////////////////
                                 HOOKS
    //////////////////////////////////////////////////////////////*/

    function beforeAoriTrade(IAoriV2.MatchingDetails calldata matching, bytes calldata hookData) public virtual returns (bool) {
       
        require(managers[tx.origin], "Only a manager can force the execution of this trade");
        require(msg.sender == aoriProtocol, "Only aoriProtocol can interact with this contract");

        if (hookData.length == 0) {
            return true;
        }

        (Instruction[] memory preSwapInstructions,) = abi.decode(hookData, (Instruction[], Instruction[]));
        _execute(preSwapInstructions);
        return true;
    }

    function afterAoriTrade(IAoriV2.MatchingDetails calldata matching, bytes calldata hookData) public virtual returns (bool) {

        require(managers[tx.origin], "Only a manager can force the execution of this trade");
        require(msg.sender == aoriProtocol, "Only aoriProtocol can trade");

        if (hookData.length == 0) {
            return true;
        }

        (, Instruction[] memory postSwapInstructions) = abi.decode(hookData, (Instruction[], Instruction[]));
        _execute(postSwapInstructions);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                                EIP-1271
    //////////////////////////////////////////////////////////////*/

    function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bytes4) {
        require(_signature.length == 65);

        // Deconstruct the signature into v, r, s
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(_signature, 32))
            // second 32 bytes.
            s := mload(add(_signature, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(_signature, 96)))
        }

        address ethSignSigner = ecrecover(_hash, v, r, s);

        // EIP1271 - dangerous if the eip151-eip1271 pairing can be found
        address eip1271Signer = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _hash
                )
            ), v, r, s);

        // check if the signature comes from a valid manager
        if (managers[ethSignSigner] || managers[eip1271Signer]) {
            return ERC1271_MAGICVALUE;
        }

        return 0x0;
    }

    /*//////////////////////////////////////////////////////////////
                                EIP-165
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 _interfaceId) public view returns (bool) {
        return
            (_interfaceId == IAoriVault.beforeAoriTrade.selector) ||
            (_interfaceId == IAoriVault.afterAoriTrade.selector);
    }
}