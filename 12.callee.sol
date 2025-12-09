// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Callee {
    uint public number = 2025;

    function getNumber() external view returns (uint) {
        return number;
    }
}
