<script lang="ts" setup>
import { reactive, ref } from 'vue'
import { Odometer, Switch } from '@element-plus/icons-vue'
import { addUserSilent, addEquipment } from '@/hooks/useWeb3';
import { ElMessageBox } from 'element-plus'; 
import { userList } from '@/assets/data/userTable.json'
import { deviceList } from '@/assets/data/deviceTable.json'
import Drawer from '@/views/layout/Drawer.vue'
 
const dalogProgress = ref(false) 
const dialogTitle = ref('正在添加用户及设备...')

const status = ref('')
const percentage = ref(0)


// 管理员批量添加用户专用
const batchAddUser = async () => {
    const users = userList
    const equipts = deviceList

    ElMessageBox.confirm('确定加入初始用户及设备？', '提示', {
        type: 'warning', cancelButtonText: '取消', confirmButtonText: '确定'
    }).then(async () => {
        dalogProgress.value = true
        try {
            for (let user of users) {
                percentage.value += 10
                await addUserSilent(user)
            }
            for (let equipt of equipts) {
                percentage.value += 10
                await addEquipment(equipt)
            }
            percentage.value = 100
            location.reload()
        } catch (error) {
            percentage.value = 100
            status.value = 'warning'
            dialogTitle.value = '请勿重复初始化数据'
            console.log(error);
        }
    })
}

const format = (percentage: number) => {
    if (percentage >= 100) {
        status.value = 'success'
        dialogTitle.value = '数据初始化成功'
        return '完成'
    } else {
        return `${Math.ceil(percentage)}%`
    }
}
 
const accountDrawer = ref()

const handleBtnDrawer = async () => {    
    accountDrawer.value.openDrawer = true
    await accountDrawer.value.refreshAccountLst()
}


</script>

<template >

    <!-- 顶栏按钮 -->
    <el-row class="row-bg">
        <el-button plain round size="small" type="success" :icon="Odometer" 
        @click="batchAddUser">初始数据</el-button>

        <el-button plain round size="small" type="primary" :icon="Switch" 
        @click="handleBtnDrawer">用户切换</el-button>
    </el-row> 
    
    <!-- 初始化进度条 -->
    <el-dialog :title="dialogTitle" v-model="dalogProgress" 
        :close-on-click-modal="false" width="30%" align-center>
        <el-progress :percentage="percentage" :format="format" :status="status" :stroke-width="15" />
    </el-dialog>

    <!-- 按钮：侧边抽屉用户列表 -->
    <Drawer ref="accountDrawer" ></Drawer>

</template>
 

  