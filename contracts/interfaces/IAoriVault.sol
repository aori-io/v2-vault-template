pragma solidity 0.8.17;

import { IAoriV2 } from "aori-v2-contracts/src/interfaces/IAoriV2.sol";
import { IAoriHook } from "aori-v2-contracts/src/interfaces/IAoriHook.sol";
import { IERC1271 } from "aori-v2-contracts/src/interfaces/IERC1271.sol";
import { IERC165 } from "aori-v2-contracts/src/interfaces/IERC165.sol";
import { IBatchExecutor } from "./IBatchExecutor.sol";

interface IAoriVault is IERC1271, IERC165, IAoriHook, IBatchExecutor {
    function beforeAoriTrade(IAoriV2.MatchingDetails calldata matching, bytes calldata hookData) external returns (bool);
    function afterAoriTrade(IAoriV2.MatchingDetails calldata matching, bytes calldata hookData) external returns (bool);
    function isValidSignature(bytes32 _hash, bytes memory _signature) external view returns (bytes4);
}