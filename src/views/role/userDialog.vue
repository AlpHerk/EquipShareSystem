<script setup lang="ts">
import type { User } from '@/stores/datatype'
import { ref } from 'vue'

const props = defineProps<{ 
    dialogVisible: { show: boolean } 
    addForm: User, 
}>()

const dialogVisible = ref(false)
const dialogTitle = ref("添加用户") 
const newIndex = 0


const handleClose  = () => {
    props.dialogVisible.show = false
}
const handleSubmit = () => {
    props.dialogVisible.show = false
}
</script>

<template>
    <el-dialog :visible.sync="dialogVisible.show" :title="dialogTitle" width="30%" center draggable destroy-on-close>
        <el-form :model="addForm" ref="refDeviceForm">
            <!-- <el-form-item label="用户头像">
                <el-input v-model.avatar="form.avatar" />
            </el-form-item> -->
            <el-form-item label="用户名称">
                <el-input v-model="addForm.name" />
            </el-form-item>
            <el-form-item label="邮箱地址">
                <el-input v-model="addForm.email" />
            </el-form-item>
            <el-form-item label="联系方式">
                <el-input v-model="addForm.tellphone" />
            </el-form-item>
            <el-form-item label="单位组织">
                <el-input v-model="addForm.organization" />
            </el-form-item>
            <el-form-item label="以太地址" v-show="newIndex<0">
                <el-input v-model="addForm.addres" autocomplete="off"/>
            </el-form-item>
        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="handleClose">取消</el-button>
                <el-button type="primary" @click="handleSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>
</template>