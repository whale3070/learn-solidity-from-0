// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Example {
    address public owner;

    constructor() {
        owner = msg.sender;  // 部署合约的人是owner
    }

    function restricted() public view returns(string memory) {
        require(msg.sender == owner, "Not authorized");
        return "You are the owner";
    }
}
