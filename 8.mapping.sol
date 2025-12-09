// SPDX-License-Identifier: MIT
// 许可证声明：指定合约使用 MIT 开源许可证，明确代码的开源授权规则
pragma solidity ^0.8.20;
// 编译器版本声明：指定使用 Solidity 0.8.20 及以上兼容版本编译（^表示兼容该主版本）

// 定义一个名为 FollowSystem 的智能合约，实现基础的关注/取消关注功能
contract FollowSystem {
    // 双向映射（嵌套映射）：存储用户的关注关系
    // 第一层 key：关注者地址（_from）；第二层 key：被关注者地址（_to）；value：是否关注（true=关注，false=取消关注）
    // private 修饰符：该映射仅能在合约内部访问，外部无法直接读写，保证数据安全
    mapping(address => mapping(address => bool)) private follow;

    // 设置关注关系的核心函数（外部可调用）
    // _to：目标被关注者地址；_follow：关注状态（true=关注，false=取消关注）
    function setFollow(address _to, bool _follow) external {
        // 安全校验：禁止用户关注自己，若条件不满足则回滚交易并抛出指定错误信息
        require(_to != msg.sender, "Cannot follow yourself");
        // 更新关注关系：将 msg.sender（调用者/关注者）对 _to（被关注者）的关注状态设置为 _follow
        follow[msg.sender][_to] = _follow;
    }

    // 检查关注关系的查询函数（外部可调用、只读）
    // _from：关注者地址；_to：被关注者地址；returns (bool)：返回是否关注的布尔值
    function checkFollow(address _from, address _to) external view returns (bool) {
        // 读取并返回 _from 对 _to 的关注状态（view 修饰符保证函数不修改合约状态，仅读取）
        return follow[_from][_to];
    }
}
