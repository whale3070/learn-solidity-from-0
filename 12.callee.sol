// SPDX-License-Identifier: MIT
// 声明源代码的许可证类型为MIT（开源许可证）
pragma solidity ^0.8.20;
// 指定Solidity编译器版本要求：大于等于0.8.20且小于0.9.0

// 1. 定义接口
interface ICallee {
    // 声明一个外部只读函数，返回无符号整数
    // external：只能从合约外部调用；view：不修改合约状态，仅读取
    function getNumber() external view returns (uint);
}

// 定义调用方合约
contract Caller {

    // 2. 用 interface（接口）方式调用目标合约的函数
    // calleeAddr：目标合约（实现了ICallee接口）的地址
    // external：只能外部调用；view：不修改当前合约状态
    // returns (uint)：返回目标合约getNumber函数的结果
    function callByInterface(address calleeAddr) 
        external 
        view 
        returns (uint)
    {
        // 将目标地址转换为ICallee接口类型，然后调用其getNumber函数
        // 接口调用是类型安全的方式，编译期会检查函数签名
        return ICallee(calleeAddr).getNumber();
    }

    // 3. 用 low-level call（底层调用）方式调用目标合约的函数
    // calleeAddr：目标合约地址
    // external：只能外部调用；view：不修改当前合约状态
    // returns (uint)：返回目标合约getNumber函数的结果
    function callByLowLevel(address calleeAddr) 
        external 
        view 
        returns (uint)
    {
        // 执行底层静态调用（staticcall）：用于调用只读函数，不修改状态
        // abi.encodeWithSignature：将函数签名编码为ABI格式（字节码）
        // 返回值：ok（调用是否成功）、data（调用返回的字节数据）
        (bool ok, bytes memory data) =
            calleeAddr.staticcall(
                abi.encodeWithSignature("getNumber()")
            );

        // 检查底层调用是否成功，失败则回滚并抛出指定错误信息
        require(ok, "low-level call failed");

        // 将返回的字节数据解码为无符号整数类型，返回给调用方
        // abi.decode：将ABI编码的字节数据还原为指定类型
        return abi.decode(data, (uint));
    }
}
