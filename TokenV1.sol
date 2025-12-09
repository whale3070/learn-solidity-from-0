// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TokenV1 {
    // 允许子合约重写
    function version() public pure virtual returns (string memory) {
        return "v1";
    }
}
