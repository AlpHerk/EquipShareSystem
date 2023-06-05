// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;  
  
import { User } from "./user.sol"; 
import { Equipment } from "./equipment.sol";
import { LibArray } from "./library.sol";  


 
// 设备状态
enum OccupyType {
    OPEN,   // 设备今日空闲或全时段空闲，可立刻预约
    LENT,   // 存在时段被租用，但可预约部分空闲时段
    MAINTAIN// 当前正在维修，但可预约部分空闲时段
}

struct Period {
    uint startTime;
    uint endTime;
    uint userid;
    OccupyType occupyType;
} 


struct Price {
    uint unitPrice;     // 租赁单位价格，从设备信息中获取
    uint totalPrice;    // 本次租赁总价，从设备信息中获取
    uint deposit;       // 设备租赁押金，从设备信息中获取
    bool isPaid;
}

struct StepsStatus { 
    uint CREATED;      // 租赁合同创建时间
    uint CANCELED;     // 租赁合同取消时间
    uint APPROVED;     // 租赁合同同意时间
    uint REJECTED;     // 租赁合同拒绝时间
    uint RETURNED;     // 租赁者归还设备
    uint COMPLETED;    // 租赁合同完成时间
}

struct LeasePact {

    // ① 创建租赁合同，仅创建租赁合同时可赋予
    // status 添加 CREATED 时间 
    uint id;            // 租约唯一编号，自增且不可干预
    uint equipmentId;   // 租赁设备编号，从租赁函数参数中获取
    string equipmentName;
    string renterName;
    address owner;      // 持有人的地址，从设备信息中获取
    address renter;     // 租赁者的地址，从设备信息中获取

    Price  price;   
    Period period;
    StepsStatus steps; 

    // ② 持有人同意租赁合同
    // 设备ID加入租赁人的租赁列表，暂不考虑租赁者一次性预约多个设备
    // 租赁时间段加入设备的租赁时间段，暂不考虑租赁者一次性租赁当前设备多个分散的时间段
    // steps 添加 APPROVED 时间

    // ③ 持有人拒绝租赁合同
    // steps 添加 REJECTED 时间  

    // ④ 双方完成租赁合同，可有第三方仲裁
    // steps 添加 COMPLETED 时间
}

contract LeaseContract {
    using LibArray for uint[]; 
    
    mapping (uint => LeasePact) private LEASES;

    mapping (address => uint[]) private RENT_LEASE; // 契约的借用人
    mapping (address => uint[]) private OWN_LEASE;  // 契约的持有人

    uint[] private LEASE_CREATED_LST;
    uint[] private LEASE_APPROVED_LST;
    uint[] private LEASE_REJECTED_LST;
    uint[] private LEASE_COMPLETED_LST; 
    uint   private LEASEID = 2023001;
  
    event eventCreateLease(string tips, uint leaseId);
    event eventCancelLease(string tips, uint leaseId);
    event eventApproveLease(string tips, uint leaseId);
    event eventRejectLease(string tips, uint leaseId);
    event eventProposeLease(string tips, uint leaseId);
    event eventCompleteLease(string tips, uint leaseId);
  
    function requireLeaseIdExist(uint leaseId) private view { 
        require(LEASES[leaseId].id != 0, unicode"请输入有效的交易ID"); 
    } 


    // 获取租赁记录信息
    function getLeasePact(uint leaseId) public view returns (LeasePact memory) {
        requireLeaseIdExist(leaseId);
        LeasePact memory lease = LEASES[leaseId];
        return lease;
    }

    function __getLeasePacts(uint[] memory leaseIdLst) private view returns (LeasePact[] memory leases) { 
        leases = new LeasePact[](leaseIdLst.length);
        for (uint i = 0; i < leaseIdLst.length; i++) {
            leases[i] = getLeasePact(leaseIdLst[i]);
        }
    }

    function getLeasePactOwned(address addr) public view returns (LeasePact[] memory) {
        return __getLeasePacts(OWN_LEASE[addr]); 
    }

    function getLeasePactRented(address addr) public view returns (LeasePact[] memory) {
        return __getLeasePacts(RENT_LEASE[addr]); 
    } 

    function getLeasePactAll() public view returns (LeasePact[] memory) { 
        return __getLeasePacts(LEASE_CREATED_LST);
    }


    // 租赁者提出租赁申请
    function leasePactCreate( 
        User memory user,
        Equipment memory equipment, 
        uint startTime,
        uint endTime
        ) internal returns (LeasePact memory) {  

        LEASEID++; 
        LEASE_CREATED_LST.push(LEASEID);
        // 写入契约双方的用户信息内
        RENT_LEASE[msg.sender].push(LEASEID);
        OWN_LEASE[equipment.owner].push(LEASEID);

        // 依次写入租赁合同的各项信息
        LeasePact storage newLease = LEASES[LEASEID];
        newLease.id          = LEASEID;
        newLease.equipmentId = equipment.id;
        newLease.owner       = equipment.owner;
        newLease.renter      = msg.sender;

        newLease.equipmentName = equipment.name;
        newLease.renterName    = user.name;

        newLease.price.deposit    = equipment.deposit;
        newLease.price.unitPrice  = equipment.unitPrice;
  
        newLease.price.totalPrice = equipment.unitPrice * (endTime-startTime) / 3600;
    
        newLease.period.startTime = startTime;
        newLease.period.endTime   = endTime;
        
        newLease.steps.CREATED = block.timestamp;
 
        // 发送事件 
        emit eventCreateLease(unicode"已创建合同", LEASEID);
        return newLease;
    }


    // 租赁者取消租赁
    function leasePactCancel(uint leaseId) internal returns (LeasePact memory) {
        requireLeaseIdExist(leaseId);
        LeasePact storage lease = LEASES[leaseId];

        require(msg.sender == lease.renter, unicode"非租赁人，没有取消权限");
        require(lease.steps.CREATED   != 0, unicode"无效的租赁合同，无法取消");
        require(lease.steps.APPROVED  == 0, unicode"租赁申请已通过，无法取消");
        require(lease.steps.REJECTED  == 0, unicode"租赁申请已拒绝，无法取消");
        lease.steps.CANCELED = block.timestamp;
        emit eventCancelLease(unicode"已取消合同", leaseId);
        return lease;
    }
 
    // 持有者批准合同
    function leasePactApprove(uint leaseId) internal returns (LeasePact memory) {
        requireLeaseIdExist(leaseId);

        LEASE_APPROVED_LST.push(leaseId);
        LeasePact storage lease = LEASES[leaseId];
        require(msg.sender == lease.owner, unicode"非合约主人，无法同意");
        require(lease.steps.CREATED   != 0, unicode"此为无效租赁合同，无法通过合同");
        require(lease.steps.APPROVED  == 0, unicode"此租赁合同已通过，请勿重复通过");
        require(lease.steps.REJECTED  == 0, unicode"此租赁合同已拒绝，无法通过合同");

        lease.steps.APPROVED = block.timestamp;
        emit eventApproveLease(unicode"合同已通过", leaseId);
        return lease;
    }

    // 持有者拒绝合同
    function leasePactReject(uint leaseId) internal returns (LeasePact memory) {
        requireLeaseIdExist(leaseId);

        LEASE_REJECTED_LST.push(leaseId);
        LeasePact storage lease = LEASES[leaseId];
        require(msg.sender == lease.owner, unicode"非合约主人，无法拒绝");

        require(lease.steps.CREATED   != 0, unicode"此为无效租赁合同，无法拒绝合同");
        require(lease.steps.APPROVED  == 0, unicode"此租赁合同已通过，无法拒绝合同");
        require(lease.steps.REJECTED  == 0, unicode"此租赁合同已拒绝，请勿重复拒绝");

        lease.steps.REJECTED = block.timestamp;
        emit eventRejectLease(unicode"合同已拒绝", leaseId);
        return lease;
    }

    // 租赁者归还设备，提出结束租赁
    function leasePactProposeEnd(uint leaseId) internal returns (LeasePact memory) {
        requireLeaseIdExist(leaseId);

        LeasePact storage lease = LEASES[leaseId];

        require(msg.sender == lease.renter, unicode"无法归还，非设备租赁者");
        //require(lease.price.isPaid, unicode"无法归还，租赁合同未完成付款");

        require(lease.steps.CREATED   != 0, unicode"此为无效租赁合同，无法发起结束");
        require(lease.steps.APPROVED  != 0, unicode"此租赁合同未通过，无法发起结束");
        require(lease.steps.COMPLETED == 0, unicode"归还错误，此租赁合同已完成"); 
        lease.steps.RETURNED = block.timestamp;
        emit eventProposeLease(unicode"合同待完成", leaseId);
        return lease;
    }

    // 持有者确认设备状态后完成此次合同
    function leasePactComplete(uint leaseId) internal returns (LeasePact memory) {
        requireLeaseIdExist(leaseId);

        LEASE_COMPLETED_LST.push(leaseId);
        LeasePact storage lease = LEASES[leaseId];

        require(lease.owner == msg.sender, unicode"非设备持有人，无法完成验收");
        require(lease.period.endTime <= block.timestamp, unicode"租赁时间未到期");

        require(lease.steps.CREATED   != 0, unicode"此为无效租赁合同，无法完成合同"); 
        require(lease.steps.APPROVED  != 0, unicode"此租赁合同还未审核通过，无法完成合同");
        require(lease.steps.COMPLETED == 0, unicode"归还错误，此租赁合同已完成");
   
        lease.steps.COMPLETED = block.timestamp; 

        OWN_LEASE[lease.owner].removeByValue(leaseId);
        RENT_LEASE[lease.renter].removeByValue(leaseId);
        emit eventCompleteLease(unicode"合同已完成", leaseId);
        return lease;
    }

    function deleteLeasePactOwned(uint leaseId) public view {
        LeasePact memory lease = LEASES[leaseId];
        require(msg.sender == lease.owner, unicode"非设备持有人，无法删除");
        require(lease.steps.COMPLETED != 0, unicode"合同未完成，无法删除");
    }
    
    function deleteLeasePactRented(uint leaseId) public view {
        LeasePact memory lease = LEASES[leaseId];
        require(msg.sender == lease.renter, unicode"非设备租用人，无法删除");
        require(lease.steps.COMPLETED != 0, unicode"合同未完成，无法删除");
    }
  
}
 