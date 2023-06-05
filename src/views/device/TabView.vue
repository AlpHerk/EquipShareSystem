<script setup lang="ts">
import AllDevice from './AllDevice.vue'
import OwnedDevice from './OwnedDevice.vue'
import RentedLeasePact from './RentedLeasePact.vue'
import { useLeasePactStore } from '@/stores/leasePactStore' 
import { ref } from 'vue'

const activeName = ref('列表1')
const store = useLeasePactStore()

</script>
<template>
    <el-tabs v-model="activeName">
        <el-tab-pane label="平台设备" name="列表1">
            <AllDevice />
        </el-tab-pane>
        <el-tab-pane label="持有设备" name="列表2">
            <OwnedDevice />
        </el-tab-pane>

        <el-tab-pane label="待还设备" name="列表3">
            <RentedLeasePact />
            <template #label>待还设备
                <el-badge :hidden="store.approvedLeasePacts.length==0" is-dot/>
            </template>
        </el-tab-pane>
    </el-tabs>

    <!-- <el-dialog v-model="isDialogVisible" title="添加新设备" width="30%" center draggable destroy-on-close>
        <el-form :model="deviceForm" ref="refDeviceForm">
            <el-form-item label="设备名称">
                <el-input v-model="deviceForm.name" autocomplete="off" />
            </el-form-item>
            <el-form-item label="设备编号">
                <el-input v-model.number="deviceForm.number" autocomplete="off" />
            </el-form-item>
            <el-form-item label="设备信息">
                <el-input v-model="deviceForm.info" autocomplete="off" />
            </el-form-item>
        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="handleCancel">取消</el-button>
                <el-button type="primary" @click="handleSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog> -->
</template>
    
 