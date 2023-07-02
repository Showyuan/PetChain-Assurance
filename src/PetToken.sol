// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "./interface/IERC20.sol";

contract Token is IERC20{

    // 代幣的總供給量
    uint public totalSupply;

    // 擁有者 => 餘額
    mapping(address => uint) public balanceOf;
    
    // 擁有者 => (被授權者 => 數量)
    mapping(address => mapping(address => uint)) public allowance;

    // 名稱及精度
    string public name;
    string public symbol;
    uint8 public decimals = 18;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /** 
        transfer 轉帳
        recipient: 收款人
        amount : 轉帳數量
     */
    function transfer(address recipient, uint amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Balance isn't enough");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /** 
        approve 授權
        spender: 被授權者
        amount : 授權使用數量
     */
    function approve(address spender, uint amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Balance isn't enough");

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
        transferFrom 從某地址轉帳
        sender: 支出地址
        recipient: 接收地址
        uint: 數量
     */
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        require(allowance[sender][msg.sender] >= amount, "Amount Not Enough!");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 製造代幣
    function mint(address owner, uint amount) external {
        balanceOf[owner] += amount;
        totalSupply += amount;
        emit Transfer(address(0), owner, amount);
    }

    // 銷毀代幣
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // 取得代幣精度
    function getDecimals() view external returns (uint8){
        return decimals;
    }
}
