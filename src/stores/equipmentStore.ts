import { defineStore } from 'pinia'
import { reactive } from 'vue'  
import { type Equipment } from '@/stores/datatype'
import { getEquipmentOwned, getEquipmentAll } from '@/hooks/useWeb3'; 



export const useEquipmentStore = defineStore('equipmentStore', () => {

    const equipmentOwned: Equipment[] = reactive([])
    const ownedEquipment = async() => {
        const items = await getEquipmentOwned()
        for (let i in items) {
            equipmentOwned[i] = items[i]
        } 
    }

    const equipmentAll: Equipment[] = reactive([])
    const allEquipment = async() => {
        const items = await getEquipmentAll()
        for (let i in items) {
            equipmentAll[i] = items[i]
        }
    } 
    
    return { equipmentOwned, equipmentAll, ownedEquipment, allEquipment}


})
