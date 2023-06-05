// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18; 
 
import { User } from "./user.sol"; 
import { LibArray } from "./library.sol"; 
import { Authority } from "./authority.sol"; 


enum OccupyType {
    OPEN,     // 设备今日空闲或全时段空闲，可立刻预约
    LENT,     // 存在时段被租用，但可预约部分空闲时段
    MAINTAIN, // 当前正在维修，但可预约部分空闲时段
    FROZEN
}

struct OccupyPeriod {
    uint id;
    uint startTime;
    uint endTime;
    address occupier;
    OccupyType occupyType;
} 

struct UseCnt {
    uint lent;      // 设备总租赁次数  
    uint maintain;  // 设备维修的次数
    uint frozen;    // 设备被冻结此时
}

struct  Equipment {

    // 此信息自动填写
    uint    id;             // 设备编号应有两部分组成(分类编号+计数器)
    address owner;          // 持有人的地址，仅添加设备时可赋值
    uint createdTime;       // 设备添加时间，仅添加设备时可赋值 
    bool isFrozen;
    

    // 添加设备可选项，仅持有人更新设备信息可修改
    string   name;          // 设备名称 
    string   category;      // 设备分类
    string   descLink;      // 设备描述链接
    string   imagesLink;    // 设备图片链接
    uint     unitPrice;     // 租赁单价/按小时计
    uint     deposit;       // 设备押金

    UseCnt useCnt; 
    OccupyPeriod[] occupyPeriod; 
}


contract EquipContract is Authority {
    using LibArray for uint[]; 

    mapping (uint => Equipment) private equipments;
    mapping (address => uint[]) private ownedEquipLst;    
    mapping (address => uint[]) private rentedEquipLst; 
    mapping (address => mapping (uint => mapping (OccupyType => uint))) private userEquipType; 

    uint[] private equipIdLst;
    uint   private equipId = 86000;
    uint   private occupyPeriodId = 2023000;

    event eventAddEquipment(string tips, uint equipmentId);
    event eventUpdateEquipment(string tips, uint equipmentId);
    event eventRentEquipment(string tips, uint equipmentId);
    event eventReturnEquipment(string tips, uint equipmentId);
    event eventMaintainEquipment(string tips, uint equipmentId);
    event eventUnMaintainEquipment(string tips, uint equipmentId);
    event eventFreezeEquipment(string tips, uint equipmentId);
    event eventUnFreezeEquipment(string tips, uint equipmentId);

    function requireEquipmentIdExist(uint id) private view { 
        require(equipments[id].id != 0, unicode"请输入有效的设备ID"); 
    } 
 
    // 获取设备信息
    function getEquipment(uint equipmentId) public view returns (Equipment memory) {
        requireEquipmentIdExist(equipmentId);
        return equipments[equipmentId];
    }
    function __getEquipments(uint[] memory lst) private view returns (Equipment[] memory equipts) { 
        equipts = new Equipment[](lst.length);
        for (uint i = 0; i < lst.length; i++) {
            uint eqid = lst[i]; 
            equipts[i] = getEquipment(eqid);
        }
    }
    function getEquipmentOwned(address addr) public view returns (Equipment[] memory) {
        return __getEquipments(ownedEquipLst[addr]);
    }
    function getEquipmentRented(address addr) public view returns (Equipment[] memory) {  
        return __getEquipments(rentedEquipLst[addr]);
    }
    function getEquipmentAll() public view returns (Equipment[] memory) {
        return __getEquipments(equipIdLst);
    }
 
    // 查询设备 occupyPeriod[] 中的空闲时段的索引
    function requireEquipAvailable(uint equipmentId, uint startTime, uint endTime) public view returns (int) {
        requireEquipmentIdExist(equipmentId);
        Equipment memory equipment = equipments[equipmentId];
        require(endTime >= startTime, unicode"开始时间需早于结束时间");
        OccupyPeriod[] memory occupyPeriod =  equipment.occupyPeriod;

        // 指定开始至结束时间是否处于设备预约列表的空闲段中
        // [预约period0, 预约period1, 预约period2, ...]
        // 即寻找两 period 间是否可容纳下 startTime~endTime 的时间段
        if (occupyPeriod.length == 0) {
            return 0;
        }
        else if (endTime<occupyPeriod[0].startTime) {
            return 0;
        }
        else if (occupyPeriod[occupyPeriod.length-1].endTime < startTime) {
            return int(occupyPeriod.length);
        }

        for (uint i = 0; i<occupyPeriod.length-1; i++) {
            bool canStart = occupyPeriod[i].endTime < startTime;
            bool canEnd   = endTime < occupyPeriod[i+1].startTime;
            if (canStart && canEnd) {
                return int(i+1); // 即可插入 period[] 的第 i+1 索引
            } 
        }  
        // 无合适插入间隔则回退函数
        if (occupyPeriod[0].occupyType == OccupyType.FROZEN) {
            require(false, unicode"该设备处于冻结状态，请联系管理员解冻");
        }
        else if (occupyPeriod[0].occupyType == OccupyType.MAINTAIN) {
            require(false, unicode"该设备处于维修状态，请联系设备持有人");
        }
        require(false, unicode"该设备在指定时段已被占用，非空闲");
        return -1; // 没有满足的插入间隔
    }

    // 将时段加入设备的 occupyPeriod[] 中
    function __occupyEquipment(uint equipmentId, uint startTime, uint endTime, OccupyType occupyType) private {
        requireEquipmentIdExist(equipmentId);
        require(userEquipType[msg.sender][equipmentId][occupyType] == 0, unicode"请勿重复出租/维修/冻结当前设备");
        if (occupyType == OccupyType.MAINTAIN) {
            require(msg.sender == equipments[equipmentId].owner, unicode"仅设备持有人可维修设备");
        } else if (occupyType == OccupyType.FROZEN) {
            require(adminer(), unicode"仅设备管理员可冻结设备");
        }

        Equipment storage equipment = equipments[equipmentId];
        OccupyPeriod[] storage occupyPeriod = equipment.occupyPeriod; 

        int sparePeriodIndex = requireEquipAvailable(equipmentId, startTime, endTime);
        uint spareIndex = uint(sparePeriodIndex);

        occupyPeriodId++;
        userEquipType[msg.sender][equipmentId][occupyType] = occupyPeriodId;
        OccupyPeriod memory newPeriod = OccupyPeriod(occupyPeriodId, startTime, endTime, msg.sender, occupyType);
        // 先将新建时段插入原本有序的数组，此步作用仅为扩充数组，若 occupyPeriod[] 为空则跳过下面的 for 循环，不再处理即可
        occupyPeriod.push(newPeriod); 
        // 对 occupyPeriod[] 进行排序，即将最后一个元素插入 sparePeriodIndex 位即可
        // 将数组第 sparePeriodIndex 号元素往后移动，最后再将 新建的period覆盖到 sparePeriodIndex 位即可
        for (uint i = spareIndex; i < occupyPeriod.length-1; i++) {
            occupyPeriod[i+1] = occupyPeriod[i]; 
        }
        // 至此，设备的占用时间列表已处理完成
        occupyPeriod[spareIndex] = newPeriod; 
        
        // 更新设备的使用统计
        if (occupyType == OccupyType.LENT) {
            equipment.useCnt.lent++;
        } else if (occupyType == OccupyType.MAINTAIN) {
            equipment.useCnt.maintain++;
        } else if (occupyType == OccupyType.FROZEN) {
            equipment.useCnt.frozen++;
            equipment.isFrozen = true;
        } 

    }

    // 删除设备的 occupyPeriod[] 中指定时段
    function __unoccupyEquipment(uint equipmentId, OccupyType occupyType) private 
    {
        requireEquipmentIdExist(equipmentId);
        uint _occupyPeriodId = userEquipType[msg.sender][equipmentId][occupyType];
        userEquipType[msg.sender][equipmentId][occupyType] = 0;
        require(_occupyPeriodId != 0, unicode"未预约/维修/冻结，无需解除");

        if (occupyType == OccupyType.MAINTAIN) {
            require(msg.sender == equipments[equipmentId].owner, unicode"仅设备持有人可完成维修");
        } else if (occupyType == OccupyType.FROZEN) {
            require(adminer(), unicode"仅设备管理员可解冻设备");
        }

        Equipment storage equipment = equipments[equipmentId];
        OccupyPeriod[] storage occupyPeriod = equipment.occupyPeriod; 
        
        for (uint i = 0; i < occupyPeriod.length; i++) {
            if (occupyPeriod[i].id == _occupyPeriodId) {
                for (uint j = i; j < occupyPeriod.length-1; j++) {
                    occupyPeriod[j] = occupyPeriod[j+1];
                } 
                if (occupyPeriod[i].occupyType == OccupyType.FROZEN) {
                    equipment.isFrozen = false;
                } 
                occupyPeriod.pop();
                break;
            }
        } 
    }

    function rentEquipment(uint equipmentId, uint startTime, uint endTime) internal {
        __occupyEquipment(equipmentId, startTime, endTime, OccupyType.LENT);

        rentedEquipLst[msg.sender].push(equipmentId); // 将设备加入租用者的列表中
        emit eventRentEquipment(unicode"已出租设备", equipmentId);
    }

    function returnEquipment(uint equipmentId) internal {
        __unoccupyEquipment(equipmentId, OccupyType.LENT); 

        rentedEquipLst[msg.sender].removeByValue(equipmentId);
        emit eventReturnEquipment(unicode"已归还设备", equipmentId);

    }
    // 默认维修时间为一天
    function maintainEquipment(uint equipmentId) public {
        __occupyEquipment(equipmentId, block.timestamp, block.timestamp + 24*60*60, OccupyType.MAINTAIN); 
        emit eventMaintainEquipment(unicode"正在维修设备", equipmentId);

    }
    function maintainEquipment(uint equipmentId, uint startTime, uint endTime) public {
        __occupyEquipment(equipmentId, startTime, endTime, OccupyType.MAINTAIN); 
        emit eventMaintainEquipment(unicode"正在维修设备", equipmentId);
    }

    function endMaintainEquipment(uint equipmentId) public { 
        __unoccupyEquipment(equipmentId, OccupyType.MAINTAIN); 
        emit eventUnMaintainEquipment(unicode"完成维修", equipmentId);
    }
    // 默认冻结时间为一天
    function freezeEquipment(uint equipmentId) public {
        // 为方便起见，此处从当前时间开始冻结设备，但设备若被他人占用，则会冻结失败
        __occupyEquipment(equipmentId, block.timestamp, block.timestamp + 10*365*24*60*60, OccupyType.FROZEN); 
        emit eventFreezeEquipment(unicode"已冻结设备", equipmentId);

    }
    function freezeEquipment(uint equipmentId, uint startTime) public { 
        __occupyEquipment(equipmentId, startTime, startTime+10*365*24*60*60, OccupyType.FROZEN); 
    }
    function unfreezeEquipment(uint equipmentId) public {
        __unoccupyEquipment(equipmentId, OccupyType.FROZEN); 
        emit eventUnFreezeEquipment(unicode"设备解除冻结", equipmentId);

    }
 
    // 添加设备
    function __addEquipment (
        address addr,
        string  memory name,  
        string  memory category,  
        string  memory descLink,  
        string  memory imagesLink,  
        uint deposit,
        uint unitPrice
        ) private {

        equipId++;
        ownedEquipLst[addr].push(equipId);

        equipIdLst.push(equipId); // 将设备以ID形式加入设备共享仓库中

        Equipment storage newEquipment = equipments[equipId];

        newEquipment.id          = equipId;
        newEquipment.owner       = addr;   
        newEquipment.createdTime = block.timestamp; 
 
        newEquipment.name        = name;
        newEquipment.category    = category; 
        newEquipment.descLink    = descLink; 
        newEquipment.imagesLink  = imagesLink; 
        newEquipment.deposit     = deposit; 
        newEquipment.unitPrice   = unitPrice;     
        emit eventAddEquipment(unicode"已添加设备", equipId);
    }
    function addEquipment (
        string  memory name,  
        string  memory category,  
        string  memory descLink,  
        string  memory imagesLink,  
        uint deposit,
        uint unitPrice
    ) public { 
        __addEquipment(msg.sender, name, category, descLink, imagesLink, deposit, unitPrice);
    }
    function addEquipment (
        address addres,
        string  memory name,  
        string  memory category,  
        string  memory descLink,  
        string  memory imagesLink,  
        uint deposit,
        uint unitPrice
    ) public isAdmin {
        __addEquipment(addres, name, category, descLink, imagesLink, deposit, unitPrice);
    }
    
    // 删除设备
    function removeEquipment(uint equipmentId) public {
        requireEquipmentIdExist(equipmentId);
        Equipment storage equipment = equipments[equipmentId];
        require(equipment.owner == msg.sender, unicode"非设备持有人，无法删除设备");  
        require(equipment.occupyPeriod.length==0, unicode"设备出租/维修/冻结中，不可删除");

        // 从设备ID列表中移除该设备
        ownedEquipLst[msg.sender].removeByValue(equipmentId); 
        equipIdLst.removeByValue(equipmentId);
    }




    // 更新设备信息
    function updateEquipment( 
        uint equipmentId,
        string  memory name,  
        string  memory category,  
        string  memory descLink,  
        string  memory imagesLink,  
        uint deposit,
        uint unitPrice 
    ) public {
        requireEquipmentIdExist(equipmentId); 
        Equipment storage equipment = equipments[equipmentId];
        require(msg.sender==equipment.owner, unicode"非设备持有人，无法修改信息");
        equipment.name       = name;
        equipment.category   = category; 
        equipment.descLink   = descLink; 
        equipment.imagesLink = imagesLink; 
        equipment.deposit    = deposit; 
        equipment.unitPrice  = unitPrice;
    } 


}




 