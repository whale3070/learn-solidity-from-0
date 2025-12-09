// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Storage vs Memory vs Calldata 教学对比实验
 * @author Yuki 学习版
 * @notice 在 Remix 部署后，你可以用不同函数调用对比结果
 */
contract StorageVsMemory {
    struct User {
        string name;
        uint age;
    }

    User public user = User("Alice", 18);

    // 修改 storage 变量（会永久改变状态）
    function changeStorage() external {
        User storage u = user; // 指向同一个 storage 数据
        u.age = 99;            // 修改将直接写入区块链
    }

    // 修改 memory 变量（仅函数内部有效，不会保存）
    function changeMemory() external view returns (User memory) {
        User memory u = user; // 创建一个副本（复制 user 的数据）
        u.age = 200;          // 修改副本，不影响原始 user
        return u;             // 返回副本结果
    }

    // 用 calldata 调用（只读，不可修改）
    function showCalldata(User calldata u)
        external
        pure
        returns (string memory, uint)
    {
        // u.age = 1; ❌ 报错：calldata 是只读的
        return (u.name, u.age);
    }

    // 辅助函数：查看链上 user 数据
    function getUser() external view returns (string memory, uint) {
        return (user.name, user.age);
    }
}
