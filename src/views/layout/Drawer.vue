<script lang="ts" setup>
import { reactive, ref, watch } from 'vue'
import { SuccessFilled, CircleCloseFilled, Switch } from '@element-plus/icons-vue'
import { addUserSilent } from '@/hooks/useWeb3'
import { ElMessage } from 'element-plus'
import { createAccount, importKeyStore } from "@/hooks/account"
import { useAccountStore } from '@/stores/accountStore' 
import type { User, AccountInfo } from '@/stores/datatype' 
 

const store = useAccountStore()   
  
const formAdd = ref({} as  User )
const showImortInput = ref(false)
const showCreateInput = ref(false)
const privateKey = ref("")
const defineName = ref("")
const password = ref("")

const formImport = reactive({
    privateKey: "",
    password: ""
})
const formCreate = reactive({
    defineName: "",
    password: ""
})

 
const rightContext = ref(false)
const contextPos = ref({ top: 0, left:0 })
const userEdit = ref(false)
const titleStr = ref("创建用户")

const openMenu = async (e:MouseEvent, address: string) => {
    rightContext.value = true
    contextPos.value.top = e.pageY + 15
    contextPos.value.left = e.pageX + 10
    for (let item of store.accountLst) {
        if (item.addres == address) {
            formAdd.value = item
        }
    }
}

const closeMenu = () => { 
  rightContext.value = false
}

watch(rightContext, () => {
    if (rightContext.value) {
        document.addEventListener('click', closeMenu, true)
    } else {
        document.removeEventListener('click', closeMenu)
    } 
})
 
const handleDetail = async () => { 
    userEdit.value = true
    titleStr.value = "用户信息" 
}

const handleAdd = async () => { 
    userEdit.value = true 
    
    for (let key in formAdd) {
        formAdd.value[key] = ""
    }
} 

const handleSubmit = async () => {
    userEdit.value = false 
    if (formAdd.value.addres) {
        formAdd.value.addres = ""
        if (await addUserSilent(formAdd.value)) {
            ElMessage.success(`用户添加成功`)
        }
    } else {
        ElMessage.warning(`添加失败，以太坊地址无效`)
    } 
} 



const openDrawer = ref(false)
const accountInfoLst = ref<AccountInfo[]>()
/**
 * 刷新账号列表
 */
const refreshAccountLst = async () => {
    await store.getAccountLst() 
    accountInfoLst.value = []

    for (let item of store.accountLst) {
        const accountinfo: AccountInfo = {
            style1: { 
                visibility: "hidden",
                display: "inherit"
            }, 
            style2: { 
                visibility: "hidden",
                display: "none"
            }, 
            type: "default",
            name: "未创建",
            address: "",
        }
        if (item.addres) {  
            accountinfo.address = item.addres
            if (item.id) accountinfo.name = item.name
            if (item.addres == store.address) {
                if (item.id) {
                    accountinfo.style1.display = "inherit"
                    accountinfo.style1.visibility = "visible"
                    accountinfo.style2.display = "none"  
                } else {
                    accountinfo.style2.display = "inherit"  
                    accountinfo.style2.visibility = "visible"  
                    accountinfo.style1.display = "none"
                    accountinfo.name = "未创建"
                }
                accountinfo.type = "success"
            }
        }
        accountInfoLst.value.push(accountinfo)
    } 
}
defineExpose({ openDrawer, refreshAccountLst }) 

 
const switchUserAccount = (address: string) => {
    for (let i in store.addressLst) { 
        if (store.addressLst[i] == address) {
            store.switchAccount(Number(i))
            openDrawer.value = false
            refreshAccountLst()
        }
    }   
}
 
const importAccount = () => {
    showImortInput.value = true
    showCreateInput.value = false 

    if (showImortInput.value && privateKey.value) {
        try {
            importKeyStore(privateKey.value, password.value)
            ElMessage.success("账户导入成功")
            refreshAccountLst()
        } catch { 
            ElMessage.warning("私钥无效，请重新输入")
        }
    }
    privateKey.value = ""
    password.value = ""
}

const createAccountHandle = async () => {
    showCreateInput.value = true
    showImortInput.value = false
    if (showCreateInput.value && defineName.value && password.value) {
        const account = createAccount(password.value)
        store.switchAccount(store.addressLst.length-1)
        globalThis.$ACCOUNT = account
        globalThis.$ADDRESS = account.address  
        
        await addUserSilent({
            name: defineName.value,
            avatar: "",
            email:"", 
            tellphone:"", 
            organization:""
        })
        ElMessage.success("创建成功，以自动导入")
        refreshAccountLst()
    }
    defineName.value = ""
    password.value = ""
}


</script>

<template> 

    <el-drawer v-model="openDrawer" size="20%">
        <template #header>
            <span>切换账户</span>
        </template>
        <template #default>
            <div class="account"> 

                <div v-for="item of accountInfoLst" style="width:100%" >
                    <el-link style="font-size: 14px;padding: 15px 0;" :underline="false" :type="item.type" 
                        @contextmenu.prevent="openMenu($event, item.address)" @click="switchUserAccount(item.address)">
                        <el-icon :style="item.style1"><SuccessFilled/></el-icon>
                        <el-icon :style="item.style2"><CircleCloseFilled/></el-icon>
                        <span style="padding:  5px 40px 5px 5px;">{{ item.name }}</span>
                        <span> {{ item.address.slice(0, 6) + "..." + item.address.slice(-4) }}</span>
                    </el-link>
                    <el-divider style="margin:0"/>
                </div>  
            </div>
            <div v-show="rightContext"
                :style="{ left: contextPos.left + 'px', top: contextPos.top + 'px', display: (rightContext ? 'block' : 'none'), flex: 'auto' }"
                class="contextmenu"> 
                <div>
                    <el-button v-show="formAdd.id" size="small" style="width:100%; border: none;" @click="handleDetail">用户详情</el-button>
                </div> 
                <div>
                    <el-button v-show="!formAdd.id" size="small" style="width:100%; border: none;" @click="handleAdd">创建用户</el-button>
                </div>
                <el-divider style="margin:0"/> 
                <div>
                    <el-button style="width:100%; border: none;" size="small">复制地址</el-button>
                </div>
                <el-divider style="margin:0"/>
                <div>
                    <el-button style="width:100%; border: none;" size="small">解锁/锁定</el-button>
                </div>

            </div> 
        </template>

        <template #footer>
            <div>
                <div>
                    <el-row :gutter="20" style="margin-bottom: 20px;" 
                    v-show="showImortInput||showCreateInput"  >
                        <el-col :span="12" style="text-align:left">
                            {{showImortInput ? "导入账户":"创建账户" }}
                        </el-col>
                        <el-col :span="12" @click="showImortInput=false; 
                        showCreateInput=false">
                        <el-button size="small" plain type="info">取消</el-button>
                    </el-col> 
                    </el-row>

                    <el-input v-model="privateKey" clearable style="margin-bottom: 10px;"
                    v-show="showImortInput" placeholder="请粘贴以太坊私钥" /> 
                      
                    <el-input v-model="defineName" clearable style="margin-bottom: 10px;"
                    v-show="showCreateInput" placeholder="用户名称" />

                    <el-input v-model="password" show-password style="margin-bottom: 20px;"
                    v-show="showImortInput||showCreateInput" placeholder="设置密码"/>
 
                </div>

                <div style="margin: 15px 0">
                    <el-button style="width: 100%;" plain 
                    :type="showCreateInput ? 'danger':'primary'" size="small" 
                    :disabled="showImortInput"
                    @click="createAccountHandle">{{showCreateInput ? "确认创建" : "创建账户"}}</el-button>
                </div>

                <div style="margin: 15px 0"> 
                    <el-button style="width: 100%;" plain :type="showImortInput ? 'danger':'primary'" 
                    :disabled="showCreateInput"
                    size="small" @click="importAccount">{{ showImortInput ? "确认导入" : "导入账户"}}</el-button>
                </div> 
            </div>
        </template>
    </el-drawer>
  

    <el-dialog v-model="userEdit" :title="titleStr" width="30%" center draggable destroy-on-close>
        <el-form :model="formAdd" ref="refDeviceForm">
            <!-- <el-form-item label="用户头像">
                <el-input v-model.avatar="form.avatar"/>
            </el-form-item> -->
            <el-form-item label="用户名称">
                <el-input v-model="formAdd.name"/>
            </el-form-item>
            <el-form-item label="用户的ID" v-show="formAdd.id">
                <el-input v-model="formAdd.id"/>
            </el-form-item>
            <el-form-item label="邮箱地址">
                <el-input v-model="formAdd.email"/>
            </el-form-item>
            <el-form-item label="联系方式">
                <el-input v-model="formAdd.tellphone"/>
            </el-form-item>
            <el-form-item label="单位组织">
                <el-input v-model="formAdd.organization"/>
            </el-form-item> 
            <el-form-item label="以太坊地址">
                <el-input v-model="formAdd.addres" disable/>
            </el-form-item> 
        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="userEdit = false">取消</el-button>
                <el-button type="primary" v-show="!formAdd.id" @click="handleSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>

</template>

<style scoped lang="scss"> 

.contextmenu  {
    width: 100px; 
    background: #ffffff;
    z-index: 3000;
    position:fixed; 
    border: 1px solid #bababa;
    border-radius: 3px;
    font-size: 12px;
    font-weight: 400;
    color: #333; 
        
    .item { 
        height: 35px;
        width: 68%;
        line-height: 35px;
        color: rgb(29, 33, 41);
        cursor: pointer;

    }
    .item:hover {
        background: rgb(229, 230, 235);
    }
} 
</style>

  