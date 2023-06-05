import { defineStore } from 'pinia'
import { reactive, ref } from 'vue'   
import { getAccount, getAddressLst } from '@/hooks/account'
import { type Account } from 'web3-core'
import { type User } from './datatype' 
import { getUser } from '@/hooks/useWeb3'

// 全局变量供 userWeb3.ts 使用
declare global {
    var $ADDRESS: string 
    var $ACCOUNT: Account
}  
 

export const useAccountStore = defineStore('account', () => {

    let address = ref("")
    let account: Account = reactive(getAccount(0))

    let addressLst = ref([])  
    let accountLst = ref([] as User[])

    /**
     * 由浏览器缓存切换账户
     * @param index 账户序号
     */
    const switchAccount = (index: number = 0) => { 
        try { 
            addressLst.value = getAddressLst() 
            
            account = reactive(getAccount(index))
            localStorage.CRRUENT = Number(index)

            address.value = addressLst.value[index]
            globalThis.$ACCOUNT = account
            globalThis.$ADDRESS = address.value 
            
        } catch {
            console.error("以太坊账户获取失败")
        }
    }

    const getAccountLst = async() => {
        addressLst.value = getAddressLst()
        accountLst.value = []
        for (let address of addressLst.value) {
            const data = await getUser(address)
            if (data) {
                accountLst.value.push(data) 
            } else {
                accountLst.value.push({
                    addres: address,
                    name: "" ,
                    avatar: "",
                    email: "",
                    tellphone: "",
                    organization: ""
                } as User)
            }
        }     
    }
    
    switchAccount(localStorage.CRRUENT)
    
    return { account, address, addressLst, accountLst, switchAccount, getAccountLst }

})
