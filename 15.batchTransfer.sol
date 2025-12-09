// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BatchStorageOptimization {
    // 用于批量存储的mapping，存储每个地址的余额
    mapping(address => uint256) public balances;
    // 记录总供应量
    uint256 public totalSupply;

    // 批量转账事件，记录每个转账的发起者、接收者地址以及转账金额
    event BatchTransfer(address indexed from, address[] to, uint256[] amounts);

    // 批量转账函数
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        // 确保接收者地址和金额的数组长度一致
        require(recipients.length == amounts.length, "Mismatched inputs");

        uint256 totalAmount = 0;  // 初始化一个变量，用于计算总转账金额

        // 预计算所有接收者需要转账的总金额
        for (uint256 i = 0; i < recipients.length; i++) {
            totalAmount += amounts[i];  // 累加每个转账金额
        }

        // 批量更新所有接收者的余额
        for (uint256 i = 0; i < recipients.length; i++) {
            balances[recipients[i]] += amounts[i];  // 给每个接收者的余额增加相应的金额
        }

        // 更新总供应量，增加转账的总金额
        totalSupply += totalAmount;

        // 触发批量转账事件，记录发起者、接收者及转账金额
        emit BatchTransfer(msg.sender, recipients, amounts);
    }
}
