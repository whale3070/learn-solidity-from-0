deposit 存款
<img width="379" height="766" alt="image" src="https://github.com/user-attachments/assets/469157e6-8c56-46c6-99af-ec1ef18f5b96" />

<img width="345" height="511" alt="image" src="https://github.com/user-attachments/assets/223b6a38-b2fc-4b66-b814-19e99c9863b1" />

在你的合约中，`balances` 和 `balanceOf` 是两个完全不同的概念，但核心关联是：`balanceOf` 是**读取 `balances` 数据的函数**，`balances` 是**存储余额数据的状态变量**。下面从定义、作用、使用方式等维度详细拆解区别：

### 一、核心定义与类型
| 特征                | `balances`                          | `balanceOf`                          |
|---------------------|-------------------------------------|--------------------------------------|
| 类型                | 状态变量（mapping 类型）            | 函数（view 类型的公共函数）          |
| 存储性质            | 永久存储在区块链上（storage）       | 无存储，仅读取数据（不修改状态）     |
| 核心作用            | 存储每个地址对应的 ETH 存款余额     | 对外提供读取指定地址余额的接口       |

### 二、详细区别拆解
#### 1. `balances`：底层数据容器
- **本质**：是 Solidity 的 `mapping(address => uint)` 类型**状态变量**，作用是“键值对存储”——以用户地址为键，以该地址的存款余额为值，永久保存在合约的存储区（storage）。
- **访问权限**：你定义的是 `public`，因此 Solidity 会**自动生成一个默认的读取函数** `balances(address account)`，功能和 `balanceOf` 几乎一致（这是 Solidity 对 public mapping/数组的语法糖）。
- **使用场景**：合约内部逻辑中直接操作（比如存款时 `balances[msg.sender] += msg.value`，取款时 `balances[msg.sender] -= amount`）。
- **示例**：合约内取款函数中，通过 `balances[msg.sender]` 直接读取/修改当前调用者的余额。

#### 2. `balanceOf`：手动定义的读取接口
- **本质**：是你手动定义的 `view` 类型函数（`view` 表示只读、不修改合约状态），核心逻辑是**返回 `balances` 中指定地址的数值**。
- **设计目的**：
  - 显式提供符合“ERC20 等代币标准”的余额查询接口（行业惯例用 `balanceOf` 作为余额查询函数名），提升可读性和兼容性；
  - 相比 Solidity 自动生成的 `balances` 读取函数，你可以自定义逻辑（比如后续扩展：对特定地址返回 0、增加权限校验等）。
- **使用场景**：外部用户/合约调用该函数，查询任意地址的存款余额（比如前端调用 `balanceOf(userAddress)` 展示用户余额）。
- **示例**：外部调用 `balanceOf(0x123...)`，函数内部读取 `balances[0x123...]` 并返回。

### 三、实操层面的区别
#### 1. 调用方式（以 Remix 为例）
- 调用 `balances`：需要传入地址参数（因为是 mapping），点击 `balances` 输入框，填入要查询的地址，再点击按钮；
- 调用 `balanceOf`：同样传入地址参数，逻辑和 `balances` 一致，但函数名更符合开发者的使用习惯。

#### 2. 扩展性
- `balances` 是固定的 mapping 结构，无法直接扩展逻辑（比如想给余额加锁、过滤无效地址，只能在操作 `balances` 的函数中处理）；
- `balanceOf` 是自定义函数，可灵活扩展：
  ```solidity
  // 扩展示例：查询黑名单地址的余额返回 0
  mapping(address => bool) public blacklist;
  function balanceOf(address account) public view returns (uint) {
      if (blacklist[account]) return 0;
      return balances[account];
  }
  ```

#### 3. 语义与规范
- `balances` 是“数据存储”的语义，偏向合约内部使用；
- `balanceOf` 是“查询接口”的语义，符合区块链行业的通用规范（比如 ERC20、ERC721 等标准都用 `balanceOf` 作为余额/持有量查询函数）。

### 四、总结
| 维度         | `balances`                          | `balanceOf`                          |
|--------------|-------------------------------------|--------------------------------------|
| 角色         | 数据“仓库”                          | 访问仓库的“窗口/接口”                |
| 存在形式     | 存储变量（占用区块链存储空间）      | 代码逻辑（不占存储空间）             |
| 核心价值     | 稳定存储余额数据                    | 灵活提供余额查询能力，符合行业规范   |
| 可定制性     | 无（固定 mapping 结构）             | 高（可自定义返回逻辑）               |

### 补充：为什么同时存在？
你的合约中，`balances` 是必须的（存储数据），而 `balanceOf` 是“锦上添花”：
- 若不定义 `balanceOf`，仅靠 Solidity 自动生成的 `balances` 读取函数也能查询余额；
- 定义 `balanceOf` 是为了遵循开发规范，让代码更易读、更易扩展（比如后续对接钱包、前端时，开发者看到 `balanceOf` 能立刻理解其作用）。

---

在 Solidity 事件（`event`）中，`indexed` 是用于**标记事件参数为“索引参数”** 的关键字，核心作用是：让该参数可以被区块链浏览器/索引工具快速检索、过滤，大幅提升事件查询的效率（非 `indexed` 参数仅作为事件“日志数据”存储，无法直接检索）。

### 一、核心原理：事件日志的存储结构
当合约触发事件（比如 `emit DepositMade(msg.sender, msg.value)`），数据会被写入以太坊的**日志（Log）** 中，日志分为两部分：
| 部分                | 作用                                                                 |
|---------------------|----------------------------------------------------------------------|
| **索引主题（Topics）** | 存储 `indexed` 参数，支持快速检索（类似数据库的“索引列”）|
| **非索引数据（Data）** | 存储非 `indexed` 参数，仅作为原始数据存储，无法直接过滤（类似数据库的“普通列”）|

`indexed` 本质是把参数从“Data 区”移到“Topics 区”，赋予其**可检索属性**。

### 二、`indexed` 的关键特性
#### 1. 数量限制
一个事件最多只能有 **3 个 `indexed` 参数**（以太坊日志的 Topics 区最多支持 4 个位置，第 0 位固定存储事件签名，剩余 3 位给索引参数）。

#### 2. 支持的类型
- ✅ 支持：`address`、`uint`/`int`、`bytes32`、`bool` 等“值类型”；
- ❌ 不支持：`string`、`bytes`（动态长度类型）—— 若强行标记，会被哈希成 `bytes32` 存储（丢失原始内容，仅能检索哈希）；
- ❌ 不支持：数组、结构体（需手动拆分为值类型）。

#### 3. 检索能力（核心价值）
以你的 `DepositMade` 为例：
```solidity
event DepositMade(address indexed account, uint amount);
```
- `account` 被标记为 `indexed`：可在区块链浏览器（如 Etherscan）、Web3 代码中，**按地址过滤所有该地址的存款事件**（比如查询“0x123... 地址所有的存款记录”）；
- `amount` 未标记：只能看到事件的完整数据，但无法按“存款金额”过滤（比如无法直接查“所有存款 1 ETH 的记录”）。

### 三、实操示例：检索 indexed 参数
#### 1. Web3.js 代码示例（过滤指定地址的存款事件）
```javascript
// 连接合约，监听 DepositMade 事件
const bankContract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);

// 过滤：仅查询 0x123... 地址的存款事件
bankContract.getPastEvents('DepositMade', {
  filter: { account: '0x1234567890123456789012345678901234567890' }, // 仅过滤 indexed 的 account
  fromBlock: 0,
  toBlock: 'latest'
}, (err, events) => {
  console.log(events); // 仅返回该地址的所有存款事件
});
```

#### 2. 区块链浏览器示例（Etherscan）
- 进入合约的“Events”页面，可通过 `account` 字段（indexed）筛选事件，快速定位指定地址的存款记录；
- 若 `account` 未标记 `indexed`，则无法直接筛选，只能逐条查看所有 DepositMade 事件。

### 四、使用建议
1. **优先标记“高频检索维度”**：
   比如你的存款事件中，`account` 是最常用的检索维度（用户查自己的存款记录），因此标记为 `indexed`；`amount` 若无需按金额过滤，可不标记。
2. **动态类型谨慎标记**：
   若要标记 `string`/`bytes`，需注意会被哈希成 `bytes32`，示例：
   ```solidity
   // 不推荐：name 被哈希后，无法直接检索原始字符串
   event Transfer(string indexed name, address indexed to);
   // 推荐：若需检索字符串，先手动转 bytes32
   event Transfer(bytes32 indexed nameHash, address indexed to);
   ```
3. **控制索引数量**：
   最多 3 个索引参数，优先给核心维度（如地址、用户 ID、交易类型），非核心维度（如金额、时间戳）可作为非索引参数。

### 五、总结
| 维度         | indexed 参数                | 非 indexed 参数              |
|--------------|-----------------------------|------------------------------|
| 存储位置     | Topics 区（索引区）         | Data 区（原始数据区）        |
| 检索能力     | 支持快速过滤、查询          | 仅能查看完整日志，无法过滤   |
| 数量限制     | 最多 3 个                   | 无数量限制                   |
| 类型支持     | 仅值类型（动态类型会哈希）  | 支持所有类型                 |

简单来说，`indexed` 就是给事件参数加“数据库索引”，让你能快速找到目标事件，而不是遍历所有事件日志——这在链上数据分析、前端展示用户操作记录时至关重要。
