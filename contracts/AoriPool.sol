// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import { ERC20 } from "solady/tokens/ERC20.sol";
import { IAoriV2 } from "aori-v2-contracts/src/interfaces/IAoriV2.sol";
import { IAoriPool, IERC20 } from "./interfaces/IAoriPool.sol";
import { IAoriHook } from "aori-v2-contracts/src/interfaces/IAoriHook.sol";

contract AoriPool is IAoriPool, ERC20 {

    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    address public owner;
    mapping (address => bool) public managers;

    address public aoriProtocol;
    address public baseToken;
    address public quoteToken;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _owner,
        address _aoriProtocol,
        address _baseToken,
        address _quoteToken
    ) ERC20() {
        owner = _owner;

        // Set owner as a manager
        managers[_owner] = true;

        // Set own contract as a manager
        managers[address(this)] = true;

        aoriProtocol = _aoriProtocol;
        baseToken = _baseToken;
        quoteToken = _quoteToken;
    }

    /*//////////////////////////////////////////////////////////////
                                 HOOKS
    //////////////////////////////////////////////////////////////*/

    function beforeAoriTrade(IAoriV2.MatchingDetails calldata matching, bytes calldata hookData) public virtual returns (bool) {

        require(
            (matching.makerOrder.inputToken == baseToken && matching.makerOrder.outputToken == quoteToken) ||
            (matching.takerOrder.inputToken == baseToken && matching.takerOrder.outputToken == quoteToken)
        , "Invalid trade");

        require(msg.sender == aoriProtocol, "Only aoriProtocol can interact with this contract");
        return true;
    }

    function afterAoriTrade(IAoriV2.MatchingDetails calldata matching, bytes calldata hookData) public virtual returns (bool) {

        require(
            (matching.makerOrder.inputToken == baseToken && matching.makerOrder.outputToken == quoteToken) ||
            (matching.takerOrder.inputToken == baseToken && matching.takerOrder.outputToken == quoteToken)
        , "Invalid trade");

        require(msg.sender == aoriProtocol, "Only aoriProtocol can trade");
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
            (_interfaceId == IAoriHook.beforeAoriTrade.selector) ||
            (_interfaceId == IAoriHook.afterAoriTrade.selector);
    }

    /*//////////////////////////////////////////////////////////////
                                 ERC20
    //////////////////////////////////////////////////////////////*/

    function name() public view virtual override returns (string memory) {
        return string(abi.encodePacked("Aori Pool: ", IERC20(baseToken).name(), " / ", IERC20(quoteToken).name()));
    }

    function symbol() public view virtual override returns (string memory) {
        return string(abi.encodePacked("ap", IERC20(baseToken).symbol(), "-", IERC20(quoteToken).symbol()));
    }

    /*//////////////////////////////////////////////////////////////
                             POOL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function depositInBase(uint256 baseAmountIn, address to) external {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 quoteAmountIn = (totalInQuote * baseAmountIn) / totalInBase;

        IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmountIn);
        IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmountIn);

        // Mint shares related
        _mint(to, totalSupply() * baseAmountIn / totalInBase);
    }

    function depositInQuote(uint256 quoteAmountIn, address to) external {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 baseAmountIn = (totalInBase * quoteAmountIn) / totalInQuote;

        IERC20(baseToken).transferFrom(msg.sender, address(this), baseAmountIn);
        IERC20(quoteToken).transferFrom(msg.sender, address(this), quoteAmountIn);

        // Mint shares related
        _mint(to, totalSupply() * quoteAmountIn / totalInQuote);
    }

    function withdrawInBase(uint256 baseAmountOut, address to, address shareHolder) external returns (uint256 shares) {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 quoteAmountOut = (totalInQuote * baseAmountOut) / totalInBase;

        uint256 sharesToBurn = (totalSupply() * baseAmountOut) / totalInBase; 
        _burn(shareHolder, sharesToBurn);

        IERC20(baseToken).transfer(to, baseAmountOut);
        IERC20(quoteToken).transfer(to, quoteAmountOut);
    }

    function withdrawInQuote(uint256 quoteAmountOut, address to, address shareHolder) external returns (uint256 shares) {
        (uint256 totalInBase, uint256 totalInQuote) = totalAssets();
        uint256 baseAmountOut = (totalInBase * quoteAmountOut) / totalInQuote;

        uint256 sharesToBurn = (totalSupply() * quoteAmountOut) / totalInQuote;
        _burn(shareHolder, sharesToBurn);

        IERC20(baseToken).transfer(to, baseAmountOut);
        IERC20(quoteToken).transfer(to, quoteAmountOut);
    }

    function totalAssets() public view returns (uint256 totalInBase, uint256 totalInQuote) {
        totalInBase = IERC20(baseToken).balanceOf(address(this));
        totalInQuote = IERC20(quoteToken).balanceOf(address(this));
    }
}