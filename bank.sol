// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    // 存储每个地址的余额
    mapping(address => uint) public balances;

    // 存款事件
    event DepositMade(address indexed account, uint amount);

    // 取款事件
    event WithdrawalMade(address indexed account, uint amount);

    // 存款函数，可接收 ETH
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }

    // 取款函数
    function withdraw(uint amount) public {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        // 向调用者发送 ETH
        payable(msg.sender).transfer(amount);

        emit WithdrawalMade(msg.sender, amount);
    }

    // 查询余额
    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }
}
