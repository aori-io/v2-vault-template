// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import { AoriVault } from "./AoriVault.sol";
import { ERC20 } from "solady/tokens/ERC20.sol";

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract AoriExternalVault is AoriVault, ERC20 {

    address public baseToken;
    address public quoteToken;

    constructor(
        address _owner,
        address _aoriProtocol,
        address _baseToken,
        address _quoteToken
    ) AoriVault(_owner, _aoriProtocol) {
        baseToken = _baseToken;
        quoteToken = _quoteToken;
    }

    function name() public view virtual override returns (string memory) {
        return string(abi.encodePacked("Aori Vaulted Pair: ", IERC20(baseToken).name(), " / ", IERC20(quoteToken).name()));
    }

    function symbol() public view virtual override returns (string memory) {
        return string(abi.encodePacked("aori-v", IERC20(baseToken).symbol(), " / ", IERC20(quoteToken).symbol()));
    }

    function depositInBase(uint256 baseAmountIn, address to) public {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 quoteAmountIn = (totalInQuote * baseAmountIn) / totalInBase;

        IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmountIn);
        IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmountIn);

        // Mint shares related
        _mint(to, totalShares() * baseAmountIn / totalInBase);
    }

    function depositInQuote(uint256 quoteAmountIn, address to) public {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 baseAmountIn = (totalInBase * quoteAmountIn) / totalInQuote;

        IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmountIn);
        IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmountIn);

        // Mint shares related
        _mint(to, totalShares() * quoteAmountIn / totalInQuote);
    }

    function withdrawInBase(uint256 baseAmountOut, address to, address owner) public returns (uint256 shares) {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 quoteAmountOut = (totalInQuote * baseAmountOut) / totalInBase;

        uint256 shares = (totalShares() * baseAmountOut) / totalInBase; 
        _burn(owner, shares);

        IERC20(baseToken).transfer(to, baseAmountOut);
        IERC20(quoteToken).transfer(to, quoteAmountOut);
    }

    function withdrawInQuote(uint256 quoteAmountOut, address to, address owner) public returns (uint256 shares) {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 baseAmountOut = (totalInBase * quoteAmountOut) / totalInQuote;

        uint256 shares = (totalShares() * quoteAmountOut) / totalInQuote;
        _burn(owner, shares);

        IERC20(baseToken).transfer(to, baseAmountOut);
        IERC20(quoteToken).transfer(to, quoteAmountOut);
    }

    function totalAssets() public view returns (uint256 totalInBase, uint256 totalInQuote) {
        totalInBase = IERC20(baseToken).balanceOf(address(this));
        totalInQuote = IERC20(quoteToken).balanceOf(address(this));
    }

    function totalShares() public view returns (uint256 totalShares) {
        totalShares = totalSupply();
    }
}