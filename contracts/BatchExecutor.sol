pragma solidity 0.8.17;
import {IBatchExecutor, Instruction } from "./interfaces/IBatchExecutor.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract BatchExecutor is IBatchExecutor {

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    address internal owner;
    mapping (address => bool) public managers;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Call(address to, uint256 value, bytes data);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _owner
    ) {
        owner = _owner;

        // Set owner as a manager
        managers[_owner] = true;

        // Set own contract as a manager
        managers[address(this)] = true;
    }

    /*//////////////////////////////////////////////////////////////
                                EXECUTE
    //////////////////////////////////////////////////////////////*/

    function execute(
        Instruction[] calldata instructions
    ) public payable {
        require(managers[msg.sender], "Only a manager can execute");
        _execute(instructions);
    }

    function _execute(
        Instruction[] memory instructions
    ) internal {
        uint256 length = instructions.length;
        for (uint256 i; i < length; i++) {
            address to = instructions[i].to;
            uint256 value = instructions[i].value;
            bytes memory _data = instructions[i].data;

            // If call to external function is not successful, revert
            (bool success, ) = to.call{value: value}(_data);
            require(success, "Call to external function failed");
            emit Call(to, value, _data);
        }
    }

    /*//////////////////////////////////////////////////////////////
                              WITHDRAWALL
    //////////////////////////////////////////////////////////////*/

    function withdrawAll(address token, address recipient) public {
        require(managers[msg.sender], "Only owner or this contract can execute");
        IERC20(token).transfer(recipient, IERC20(token).balanceOf(address(this)));
    }

    /*//////////////////////////////////////////////////////////////
                               MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    function setManager(address _manager, bool _isManager) external {
        require(owner == msg.sender, "Only owner can call this function");
        managers[_manager] = _isManager;
    }

    /*//////////////////////////////////////////////////////////////
                                  MISC
    //////////////////////////////////////////////////////////////*/

    fallback() external payable {}

    receive() external payable {}
}
