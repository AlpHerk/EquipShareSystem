import { defineStore } from 'pinia'
import { reactive } from 'vue'  
import { getUserAll } from '@/hooks/useWeb3';
import { type User } from '@/stores/datatype'


export const useUserStore = defineStore('userStore', () => {

    const userAll: User[] = reactive([]) 
    const allUser = async () => {
        // 加载所有的用户信息
        const items = await getUserAll();
        for (let i in items) {
            userAll[i] = items[i]
        }
    }  
    
    return { userAll, allUser }
})
