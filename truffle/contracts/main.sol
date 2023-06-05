// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;  

import { Authority } from "./authority.sol"; 
import { TokenContract } from "./token.sol"; 
import { UserContract, User } from "./user.sol";
import { LeaseContract, LeasePact } from "./lease.sol";
import { EquipContract, Equipment } from "./equipment.sol";
 
 
contract EquipShare is Authority, TokenContract, UserContract, EquipContract, LeaseContract {
 
    function reserveEquipment(uint equipmentId, uint startTime, uint endTime) public {
        // 查询设备是否空闲
        requireEquipAvailable(equipmentId, startTime, endTime); 

        // 租用方起草租赁合同
        User memory user = UserContract.getUser(msg.sender);
        Equipment memory equipment = EquipContract.getEquipment(equipmentId);
        LeasePact memory lease = LeaseContract.leasePactCreate(user, equipment, startTime, endTime);

        // 租用方支付押金
        TokenContract.transfer(lease.owner, lease.price.deposit);
    }

    function reserveCancel(uint leaseId) public {
        // 租用方取消租赁合同
        LeasePact memory lease = LeaseContract.leasePactCancel(leaseId);

        // 租用方从持有方处退回押金
        TokenContract.transferFrom(lease.owner, lease.price.deposit);
    }
 
    function reserveApprove(uint leaseId) public {
        // 持有方同意租赁合同
        LeasePact memory lease = LeaseContract.leasePactApprove(leaseId);

        // 持有方从租用方获取租金
        TokenContract.transferFrom(lease.renter, lease.price.totalPrice);

        // 持有方交付设备
        EquipContract.rentEquipment(lease.equipmentId, lease.period.startTime, lease.period.endTime);
    }

    function reserveReject(uint leaseId) public {
        // 持有方拒绝合同
        LeasePact memory lease = LeaseContract.leasePactReject(leaseId);

        // 持有方退回押金
        TokenContract.transfer(lease.renter, lease.price.deposit);
    }


    function reservePopose(uint leaseId) public {
        // 租用方提出完成合同
        LeasePact memory lease = LeaseContract.leasePactProposeEnd(leaseId);

        // 租用方归还设备
        EquipContract.returnEquipment(lease.equipmentId);
 
    }

    // 持有者确认设备状态后完成此次合同
    function reserveComplete(uint leaseId) public {
        // 持有方确认完成合同
        LeasePact memory lease = LeaseContract.leasePactComplete(leaseId);
    
        // 逾期处理 
        uint refund  = lease.price.deposit;
        uint overdue = block.timestamp - lease.period.endTime ;
        refund -= overdue * lease.price.deposit / 10;
        refund  = refund > 0 ? refund : 0; 
        
        // 租用方从持有方退回押金
        TokenContract.transfer(lease.renter, lease.price.deposit); 
    }
  
}

 