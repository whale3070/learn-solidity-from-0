// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

// 定义一个购买合约
contract Purchase {
    uint public value;  // 存储交易的金额（卖方收到的金额的一半）
    address payable public seller;  // 卖方地址
    address payable public buyer;   // 买方地址

    // 状态枚举：Created（已创建）、Locked（已锁定）、Release（已释放）、Inactive（无效）
    enum State { Created, Locked, Release, Inactive }
    State public state;  // 当前状态，默认值为 Created

    // 修饰符，检查某个条件是否成立，如果不成立，则抛出错误
    modifier condition(bool condition_) {
        require(condition_);
        _;  // 继续执行剩余的代码
    }

    // 只有买方才能调用这个函数
    error OnlyBuyer();

    // 只有卖方才能调用这个函数
    error OnlySeller();

    // 当前状态下无法调用该函数
    error InvalidState();

    // 交易金额必须为偶数
    error ValueNotEven();

    // 修饰符：只有买方才能调用该函数
    modifier onlyBuyer() {
        if (msg.sender != buyer)  // 如果调用者不是买方
            revert OnlyBuyer();  // 抛出 OnlyBuyer 错误
        _;  // 继续执行剩余的代码
    }

    // 修饰符：只有卖方才能调用该函数
    modifier onlySeller() {
        if (msg.sender != seller)  // 如果调用者不是卖方
            revert OnlySeller();  // 抛出 OnlySeller 错误
        _;  // 继续执行剩余的代码
    }

    // 修饰符：确保函数在指定的状态下调用
    modifier inState(State state_) {
        if (state != state_)  // 如果当前状态与预期状态不匹配
            revert InvalidState();  // 抛出 InvalidState 错误
        _;  // 继续执行剩余的代码
    }

    // 定义事件，供前端监听
    event Aborted();  // 购买被终止
    event PurchaseConfirmed();  // 购买已确认
    event ItemReceived();  // 物品已收到
    event SellerRefunded();  // 卖方已退款

    // 构造函数，初始化合约，卖方为部署者，交易金额为传入的半数ETH
    constructor() payable {
        seller = payable(msg.sender);  // 卖方地址为合约部署者的地址
        value = msg.value / 2;  // 买方支付的金额的一半
        if ((2 * value) != msg.value)  // 如果提供的 ETH 不是偶数，则抛出错误
            revert ValueNotEven();  // 抛出 ValueNotEven 错误
    }

    // 终止购买并收回 ETH，只有卖方可以在合约创建状态时调用
    function abort()
        external
        onlySeller  // 只有卖方可以调用
        inState(State.Created)  // 必须在状态为 Created 时调用
    {
        emit Aborted();  // 触发终止购买事件
        state = State.Inactive;  // 改变合约状态为 Inactive（无效）
        seller.transfer(address(this).balance);  // 将合约中的所有 ETH 转回卖方
    }

    // 买方确认购买，交易金额必须为 2 * value
    function confirmPurchase()
        external
        inState(State.Created)  // 必须在状态为 Created 时调用
        condition(msg.value == (2 * value))  // 确保支付金额为 2 * value
        payable  // 允许支付 ETH
    {
        emit PurchaseConfirmed();  // 触发购买确认事件
        buyer = payable(msg.sender);  // 设置买方地址
        state = State.Locked;  // 改变合约状态为 Locked（已锁定）
    }

    // 买方确认物品已收到，这将释放锁定的 ETH
    function confirmReceived()
        external
        onlyBuyer  // 只有买方可以调用
        inState(State.Locked)  // 必须在状态为 Locked 时调用
    {
        emit ItemReceived();  // 触发物品已收到事件
        state = State.Release;  // 改变合约状态为 Release（已释放）
        buyer.transfer(value);  // 将 value 发送给买方
    }

    // 卖方退款功能，即退还卖方锁定的资金
    function refundSeller()
        external
        onlySeller  // 只有卖方可以调用
        inState(State.Release)  // 必须在状态为 Release 时调用
    {
        emit SellerRefunded();  // 触发卖方退款事件
        state = State.Inactive;  // 改变合约状态为 Inactive（无效）
        seller.transfer(3 * value);  // 将 3 * value 发送给卖方
    }
}
