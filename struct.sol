// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserManager {
    // 定义用户信息结构体
    struct UserInfo {
        address addr;
        string nickname;
        uint256 score;
    }

    // 地址 => 用户信息 的映射
    mapping(address => UserInfo) private users;

    // 添加用户
    function addUser(address _addr, string memory _nickname, uint256 _score) external {
        require(users[_addr].addr == address(0), "User already exists");
        users[_addr] = UserInfo({
            addr: _addr,
            nickname: _nickname,
            score: _score
        });
    }

    // 编辑用户分数
    function editScore(address _addr, uint256 _newScore) external {
        require(users[_addr].addr != address(0), "User does not exist");
        users[_addr].score = _newScore;
    }

    // 获取用户信息
    function getUser(address _addr) external view returns (address, string memory, uint256) {
        require(users[_addr].addr != address(0), "User does not exist");
        UserInfo memory user = users[_addr];
        return (user.addr, user.nickname, user.score);
    }
}
