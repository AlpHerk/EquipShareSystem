import { reactive } from 'vue'  
import { defineStore } from 'pinia'
import { type LeasePact } from '@/stores/datatype'
import { getLeasePactOwned, getLeasePactRented, getLeasePactAll } from '@/hooks/useWeb3';  


export const useLeasePactStore = defineStore('leasePactStore', () => {
 
    const needApprove: LeasePact[] = reactive([])
    const needReturn : LeasePact[] = reactive([])
    const ownedLeasePact = async() => {
        const items = await getLeasePactOwned()
        let cntApprove = 0
        let cntReturn  = 0 
 
        for (let i in items) {
            if (items[i].steps.APPROVED == 0 && items[i].steps.REJECTED == 0) {
                needApprove[cntApprove] = items[i]
                cntApprove++
            } else if (items[i].steps.APPROVED != 0 && items[i].steps.RETURNED == 0) {
                needReturn[cntReturn] = items[i]
                cntReturn++
            }
        }
    }


    const approvedLeasePacts: LeasePact[] = reactive([])
    const rejectedLeasePacts: LeasePact[] = reactive([])
    const rentedLeasePact = async() => {
        const items = await getLeasePactRented()
        let cntApprove = 0
        let cntreject  = 0

        for (let i in items) {
            if (items[i].steps.APPROVED != 0 && items[i].steps.RETURNED == 0) {
                approvedLeasePacts[cntApprove] = items[i]
                cntApprove++
            } else if (items[i].steps.REJECTED != 0) {
                rejectedLeasePacts[cntreject] = items[i]
                cntreject++
            }  
        }
    } 

    const allLeasePacts: LeasePact[] = reactive([])
    const allLeasePact = async () => {
        const items = await getLeasePactAll();
        for (let i in items) {
            allLeasePacts[i] = items[i]
        } 
    }

    return { 
        needApprove, needReturn, ownedLeasePact,
        approvedLeasePacts, rejectedLeasePacts, rentedLeasePact,
        allLeasePacts, allLeasePact
    }

}) 