// SPDX-License-Identifier: MIT
// 许可证声明：指定合约采用 MIT 开源许可证，明确代码的开源授权规则
pragma solidity ^0.8.24;
// 编译器版本声明：指定使用 Solidity 0.8.24 及以上兼容版本编译（^表示主版本兼容）

import "./TokenV1.sol";
// 导入同目录下的 TokenV1.sol 合约文件，使当前上层合约能继承/使用下层合约 TokenV1 的内容
// 注意：导入路径需与实际文件位置匹配，"./" 表示当前目录

// 定义 TokenV2 合约（上层合约），继承自 TokenV1 合约（下层合约）（Solidity 中用 is 实现继承）
// TokenV2（上层合约）会继承 TokenV1（下层合约）的所有非私有（public/externa/internal）状态变量和函数
contract TokenV2 is TokenV1 {
    // 重写下层合约（TokenV1）中的 version 函数
    // public：函数可见性（外部/内部均可调用）
    // pure：函数不读取也不修改合约状态，仅返回固定值（gas 消耗极低）
    // override：声明该函数重写下层合约的同名函数（必须加，否则编译报错）
    // returns (string memory)：返回值为字符串类型（memory 表示字符串存储在内存中）
    function version() public pure override returns (string memory) {
        // 返回字符串 "v2"，覆盖下层合约 TokenV1 中 version 函数的返回值
        return "v2";
    }
}
