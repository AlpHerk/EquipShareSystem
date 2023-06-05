// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18; 
import { Authority } from "./authority.sol"; 

struct User {
    // 此信息自动填写
    uint    id;             // 用户账户
    address addres;         // 前端注册的私钥导出地址
    uint createTime;        // 用户创建时间

    // 用户自定义项
    string  name;           // 用户昵称，可自定义修改
    string  avatar;
    string  email;
    string  tellphone;
    string  organization;

    // 管理员可控制修改 
    uint    rating;          // 用户信用评级 
    uint[]  permission;      // 用户权限等级 
}

contract UserContract is Authority {
   
    mapping (uint => address) private userAddr;
    mapping (address => User) private users; 

    address[] private userLst;  
    uint   private userId = 10000; 

    event eventAddUser(string tips, uint userId);
    event eventUpdateUser(string tips, uint userId);
 
    // 查询用户信息
    function getUserByID(uint usrid) public view returns (User memory) {
        require(users[userAddr[usrid]].id != 0, unicode"请输入有效的用户ID");  
        return users[userAddr[usrid]];
    }
    function getUser(address addrs) public view returns (User memory) {
        require(users[addrs].id != 0, unicode"该以太坊地址的用户为空，请创建用户");  
        return users[addrs];
    } 
    function getUserBatch(uint startIndex, uint length) public view returns (User[] memory _users) {
        _users = new User[](length);
        for(uint i=startIndex; i<userLst.length; i++) { 
            _users[i] = getUser(userLst[i]);
        } 
    } 
    function getUserAll()  public view returns (User[] memory _users) {
        require(adminer(), unicode"权限不足, 无法获取所有用户信息");
        return getUserBatch(0, userLst.length); 
    } 


    // 添加用户 
    function __addUser (
        address addrs,
        string memory name, 
        string memory avatar,
        string memory email,
        string memory tellphone,
        string memory organization
    ) private {
        require(users[addrs].id == 0, unicode"该以太坊地址已存在用户，请勿重复添加");

        userId++; 

        userAddr[userId] = addrs;
        userLst.push(addrs);

        User storage newUser = users[addrs];
        newUser.addres = addrs;
        newUser.id     = userId;
        newUser.createTime = block.timestamp; 

        newUser.name   = name;
        newUser.avatar = avatar;
        newUser.email     = email;
        newUser.tellphone = tellphone;
        newUser.organization = organization;
        emit eventAddUser(unicode"已添加用户", userId);
    }
    function addUser (
        string memory name,
        string memory avatar,
        string memory email,
        string memory tellphone,
        string memory organization
    ) public {
        __addUser(msg.sender, name, avatar, email, tellphone, organization);
    }
    function addUser (
        address addrs,
        string memory name,
        string memory avatar,
        string memory email,
        string memory tellphone,
        string memory organization
    ) public {  
        require(adminer(), unicode"权限不足, 无法为他人地址创建用户"); 
        __addUser(addrs, name, avatar, email, tellphone, organization);
    }


    // 修改用户信息 
    function __updateUser (
        address addrs,
        string memory name,
        string memory avatar,
        string memory email,
        string memory tellphone,
        string memory organization
    ) private { 
        require(users[addrs].id != 0, unicode"该以太坊地址未创建平台账户，请先创建");

        User storage user = users[addrs];

        user.name   = name;
        user.avatar = avatar;
        user.email     = email;
        user.tellphone = tellphone;
        user.organization = organization;
        emit eventUpdateUser(unicode"已修改用户", userId);
    }
    function updateUser ( 
        string memory name,
        string memory avatar,
        string memory email,
        string memory tellphone,
        string memory organization
    ) public {
        __updateUser(msg.sender, name, avatar, email, tellphone, organization);
    }
    function updateUser (
        address addrs,
        string memory name,
        string memory avatar,
        string memory email,
        string memory tellphone,
        string memory organization
    ) public { 
        require(adminer(), unicode"权限不足, 无法修改其他用户信息");
        __updateUser(addrs, name, avatar, email, tellphone, organization);
    }
 

}