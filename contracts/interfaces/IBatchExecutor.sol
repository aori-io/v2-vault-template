pragma solidity 0.8.17;

struct Instruction {
    address to;
    uint256 value;
    bytes data;
}

interface IBatchExecutor {
    function execute(Instruction[] calldata instructions) external payable;
    function withdrawAll(address token, address recipient) external;
    function setManager(address _manager, bool _isManager) external;
}