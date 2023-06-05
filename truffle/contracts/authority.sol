// SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.18;  

contract Authority {
    address private OWNER;
    mapping(address => bool) private ADMIN;

    constructor() {
        OWNER = msg.sender;
        ADMIN[OWNER] = true; 
    }

    modifier isOwner() {
        require(msg.sender == OWNER, unicode"非合约拥有者");
        _;
    }
    modifier isAdmin() {
        require(ADMIN[msg.sender] == true, unicode"无管理员权限");
        _;
    } 
    function adminer() internal view returns (bool) {
        return ADMIN[msg.sender];
    }
    function addAdmin(address addrs) public isOwner {
        ADMIN[addrs] = true;
    } 
    function removeAdmin(address addrs) public isOwner { 
        ADMIN[addrs] = false;
    }
} 