<script lang="ts" setup>

import { Setting, SetUp, Notification, Calendar, User, Postcard } from '@element-plus/icons-vue'
import { useLeasePactStore } from '@/stores/leasePactStore'
import { onMounted, watch } from 'vue' 
import { ElNotification } from 'element-plus'
 

const store = useLeasePactStore()

onMounted(async () => { 
        store.ownedLeasePact()    
    }
)  

watch(() => store.needApprove.length, async (newVal, oldVal) => {
    if (newVal - oldVal > 0) { 
        ElNotification({
            title: '设备预约申请',
            message: "您有新的预约请求待审核",
            position: 'bottom-right',
            type: 'success',
        })
    }
}, { immediate:false }) 

</script>
<template>
    <el-menu class="el-menu-vertical-demo" active-text-color="#ffd04b" background-color="#0000" default-active="1"
        :router="true" text-color="#fff">

        <div style="height:60px; padding:10px 0 0 25px;">
            <img src="@/assets/icons/logo_njtech_white.png" width="150">
        </div>

        <el-menu-item index="/self">
            <el-icon>
                <User />
            </el-icon>
            <span>个人信息</span>
        </el-menu-item>

        <el-menu-item index="/notice">
            <el-icon>
                <el-badge :hidden="true" is-dot>
                    <Notification />
                </el-badge>
            </el-icon>
            <span>通知公告</span>
        </el-menu-item>

        <el-menu-item index="/user">
            <el-icon>
                <Postcard />
            </el-icon>
            <span>用户管理</span>
        </el-menu-item>

        <el-menu-item index="/device">
            <el-icon>
                <SetUp />
            </el-icon>
            <span>仪器设备</span>
        </el-menu-item>
        <el-menu-item index="/reserve">
            <el-icon>
                <el-badge :hidden="store.needApprove.length==0" is-dot>
                    <Calendar />
                </el-badge>
            </el-icon>
            <span>预约审批</span>

        </el-menu-item>


        <el-menu-item index="/system">
            <el-icon>
                <Setting />
            </el-icon>
            <span>系统功能</span>
        </el-menu-item>

    </el-menu>
</template> 
  
