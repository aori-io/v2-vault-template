pragma solidity >=0.8.17;

import { IERC1271 } from "aori-v2-contracts/src/interfaces/IERC1271.sol";
import { IERC165 } from "aori-v2-contracts/src/interfaces/IERC165.sol";
import { IAoriHook } from "aori-v2-contracts/src/interfaces/IAoriHook.sol";

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IAoriPool is IERC1271, IERC165, IAoriHook {
    function depositInBase(uint256 baseAmountIn, address to) external;
    function depositInQuote(uint256 quoteAmountIn, address to) external;
    function withdrawInBase(uint256 baseAmountOut, address to, address owner) external returns (uint256 shares);
    function withdrawInQuote(uint256 quoteAmountOut, address to, address owner) external returns (uint256 shares);
    function totalAssets() external view returns (uint256 totalInBase, uint256 totalInQuote);
}