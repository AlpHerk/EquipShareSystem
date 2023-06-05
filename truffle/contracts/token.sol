// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;
  

contract TokenContract {

    //代币信息结构体
    struct Token {
        uint    id;             //代币ID
        string  name;           //代币名称
        string  symbol;         //代币符号
        uint    decimals;       //代币精度
        uint    totalSupply;    //代币总发行量
        mapping(address => uint) balanceOf;    //代币余额
        mapping(address => mapping(address => uint)) allowance;
    }

    Token public token;
    mapping(address => bool) public haveGotEth;

    constructor() { 
        token.name      = unicode"虚拟币";
        token.symbol    = unicode"￥";
        token.decimals  = 10000;
        token.totalSupply = 1_00000;
        token.balanceOf[msg.sender] = 1_00000;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);


    function balanceOf(address account) public view returns (uint256) {
        return token.balanceOf[account];
    }

    function allowance(address owner, address spender) internal view returns (uint256) {

    }

    function approve(address to, uint amount) internal returns (bool) {
        token.allowance[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(token.balanceOf[msg.sender] >= amount, unicode"您的账号余额不足");
        token.balanceOf[msg.sender] -= amount;
        token.balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, uint256 amount
    ) internal returns (bool) {
        // require(token.allowance[from][msg.sender] >= amount, unicode"已授权余额不足");
        // require(token.balanceOf[from] >= amount, unicode"所提账户余额不足");
        // token.allowance[from][msg.sender] -= amount; 
        token.balanceOf[from] -= amount;
        token.balanceOf[from] += amount;
        emit Transfer(from, msg.sender, amount);
        return true;
    }
}