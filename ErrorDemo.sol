// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ErrorDemo {
    // Custom Error（节省 gas，通常在复杂项目中使用）
    error NotEnoughBalance(uint256 requested, uint256 available);

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor() {
        totalSupply = 999;
        balanceOf[msg.sender] = 1000;
    }

    // 1. 使用 require：输入验证 /权限 / 状态验证
    function transfer(address to, uint256 amount) external {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }

    // 2. 使用 revert：手工抛错（推荐在复杂逻辑中使用）
    function withdraw(uint256 amount) external {
        uint256 bal = balanceOf[msg.sender];

        if (amount > bal) {
            revert NotEnoughBalance(amount, bal);
        }

        balanceOf[msg.sender] -= amount;
    }

    // 3. 使用 assert：用于断言永远为真（仅内部检查）
    //    totalSupply 永不减少（根据业务逻辑）
    function internalInvariantCheck() external view returns (bool) {
        // assert 失败代表代码存在 bug
        assert(totalSupply >= 999);
        return true;
    }

    // 4. 显示触发 revert（手工示例）
    function forceFail() external pure {
        revert("Manually reverted");
    }
}
