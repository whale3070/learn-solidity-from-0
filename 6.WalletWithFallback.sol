// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WalletWithFallback {

    // 记录 fallback 被调用时的信息
    event FallbackCalled(address sender, uint value, bytes data);

    // 接收 ETH 的 receive 函数，只要 msg.data 为空就触发
    receive() external payable {
        // 可以不写内容，只要 payable 就能收 ETH
    }

    // fallback 函数：有 data，或找不到函数签名时触发
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }

    // 查询当前合约内 ETH 余额
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
