// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC20 {
    string public name;
    string public symbol;
    //uint8 public decimals = 18;
    uint public totalSupply;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowances;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view returns (uint) {
        return allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        uint currentAllowance = allowances[from][msg.sender];
        require(currentAllowance >= amount, "insufficient allowance");
        allowances[from][msg.sender] = currentAllowance - amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint amount) internal {
        require(from != address(0), "from zero");
        require(to != address(0), "to zero");
        require(balances[from] >= amount, "balance too low");

        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint amount) internal {
        require(to != address(0), "mint to zero");
        totalSupply += amount;
        balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint amount) internal {
        require(from != address(0), "burn zero");
        require(balances[from] >= amount, "burn too much");
        balances[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }
    function mint(address to, uint amount) public {
    _mint(to, amount);
}

}
