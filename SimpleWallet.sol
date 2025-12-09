// SPDX-License-Identifier: MIT
// 许可证声明：指定合约采用 MIT 开源许可证，明确代码的授权规则
pragma solidity ^0.8.20;
// 编译器版本声明：指定使用 Solidity 0.8.20 及以上兼容版本编译（^表示主版本兼容）

// 定义一个名为 SimpleWallet 的智能合约，实现基础的白名单钱包功能
contract SimpleWallet {

    // 1. 余额映射：存储每个用户的合约内余额
    // key：用户地址；value：余额（uint 默认为 uint256，单位是 wei）
    // public 修饰符：自动生成 getter 函数，外部可通过 balances(address) 查询指定地址余额
    mapping(address => uint) public balances;

    // 2. 白名单映射：标记地址是否在白名单内
    // key：用户地址；value：是否在白名单（true=在，false=不在）
    // public 修饰符：自动生成 getter 函数，外部可通过 whitelist(address) 查询白名单状态
    mapping(address => bool) public whitelist;

    // ========== 事件定义（Events）==========
    // 事件：添加白名单成功时触发，indexed 关键字让该字段可被索引（方便前端/链上查询）
    event Whitelisted(address indexed user);
    // 事件：移除白名单成功时触发
    event Removed(address indexed user);
    // 事件：存入资金成功时触发，记录存入地址和金额
    event Deposited(address indexed user, uint amount);
    // 事件：转账成功时触发，记录转账发起方、接收方和金额
    event Transferred(address indexed from, address indexed to, uint amount);

    // ========== 自定义修饰符（Modifier）==========
    // 修饰符：限制仅白名单内的地址可调用被修饰的函数
    // modifier 是 Solidity 语法糖，用于复用校验逻辑
    modifier onlyWhitelist() {
        // 校验：调用者（msg.sender）必须在白名单内，否则回滚并抛出指定错误
        require(whitelist[msg.sender], "Not in whitelist");
        _; // 占位符，表示执行被修饰函数的核心逻辑
    }

    // ========== 公共可调用函数 ==========

    // 存钱函数：向合约存入 ETH（payable 修饰符表示函数可接收 ETH）
    function deposit() external payable {
        // 更新调用者的余额：原有余额 + 本次存入的 ETH 金额（msg.value 是内置变量，单位 wei）
        balances[msg.sender] += msg.value;
        // 触发存款事件，记录存款地址和金额（方便链下监听）
        emit Deposited(msg.sender, msg.value);
    }

    // 加白名单函数：将指定地址加入白名单（外部可调用）
    function addWhitelist(address user) external {
        // 将目标地址的白名单状态设为 true
        whitelist[user] = true;
        // 触发添加白名单事件
        emit Whitelisted(user);
    }

    // 移除白名单函数：将指定地址移出白名单（外部可调用）
    function removeWhitelist(address user) external {
        // 将目标地址的白名单状态设为 false
        whitelist[user] = false;
        // 触发移除白名单事件
        emit Removed(user);
    }

    // 转账函数：从调用者余额向目标地址转账（仅白名单用户可调用，被 onlyWhitelist 修饰）
    // to：转账接收地址；amount：转账金额（单位 wei）
    function transferTo(address to, uint amount) external onlyWhitelist {
        // 校验：调用者的合约内余额 ≥ 转账金额，否则回滚并提示“余额不足”
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 扣减调用者的余额
        balances[msg.sender] -= amount;
        // 增加接收方的余额
        balances[to] += amount;

        // 触发转账事件，记录转账双方和金额
        emit Transferred(msg.sender, to, amount);
    }
}
