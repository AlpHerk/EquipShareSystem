<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { type User } from '@/stores/datatype'
import { useAccountStore } from "@/stores/accountStore"
import { getBalance, getUser, updateSelfUser } from '@/hooks/useWeb3'
import { Iphone, Location, OfficeBuilding, Key, Message, User as userIcon, Money } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus' 

onMounted(async () => { 
 
    const store = useAccountStore() 

    balance.value = await getBalance(store.address)
    form.value = await getUser(store.address)
    
    if (form.value) {
        loading.value = false
        avatarUrl.value = form.value.avatar
    }
})


const balance = ref(0)
const editVisible = ref(false)
const loading = ref(true)

const form = ref<User>({
    name: "",
    avatar: "",
    email: "",
    tellphone: "",
    organization: "",
    addres: ""
})

const avatarUrl = ref("")

const iconStyle = ref({
    marginRight: '10px',
    color: '#1D56AB'
})

const handleEdit = () => {
    editVisible.value = true
}
const handleSubmit = async () => {
    editVisible.value = false

    ElMessageBox.confirm('确定要修改吗？', '提示', { type: 'warning', cancelButtonText: '取消', confirmButtonText: '确定' })
        .then(async () => {
            console.log(form.value);

            const res = await updateSelfUser(form.value)
            if (res) {
                ElMessage.success(`用户信息修改成功`)
            } else {
                ElMessage.warning(`用户信息修改失败`)
            }
        })
}
</script> 

<template>
    <div class="container">
        
        <div class="avtar">
            <el-row style="align-items:flex-end;">
                <el-avatar style="margin-left: 15px;" shape="square" size="large" :src="avatarUrl" />

                <el-button type="primary" style="margin-left: 35px;" size="small"
                    @click.prevent="handleEdit">修改信息</el-button>

                <el-button type="success" size="small">账号设置</el-button>

            </el-row>
        </div>

        <el-descriptions :column="1" size="large" border>

            <el-descriptions-item label-class-name="my-label" class-name="my-content">
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <userIcon />
                        </el-icon>
                        用户
                    </div>
                </template>
                <el-skeleton animated :loading="loading" style="height:22px">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>
                        {{ form.name }} 
                    </template>
                </el-skeleton>
            </el-descriptions-item>

            <el-descriptions-item label-class-name="my-label" class-name="my-content">
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <Key />
                        </el-icon>
                        权限
                    </div>
                </template>
                
                <el-skeleton animated :loading="loading" style="height:22px">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>{{ form.addres == "0x8523E67705C59b1Bd31e703a514c4Dc87e1e84c5"?"超级管理员":"普通用户" }}
                    </template>
                </el-skeleton>

            </el-descriptions-item>

            <el-descriptions-item>
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <iphone />
                        </el-icon>
                        手机
                    </div>
                </template>

                <el-skeleton animated :loading="loading" style="height:22px">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>
                        {{ form.tellphone }}
                    </template>
                </el-skeleton> 

            </el-descriptions-item>

            <el-descriptions-item>
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <Message />
                        </el-icon>
                        邮箱
                    </div>
                </template>
                
                <el-skeleton animated :loading="loading" style="height:22px">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>
                        {{ form.email }}
                    </template>
                </el-skeleton>

            </el-descriptions-item>

            <el-descriptions-item>
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <office-building />
                        </el-icon>
                        单位
                    </div>
                </template>

                <el-skeleton animated :loading="loading" style="height:22px">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>
                        {{ form.organization }} <el-tag size="small">高校</el-tag>
                    </template>
                </el-skeleton>
 
            </el-descriptions-item>

            <el-descriptions-item>
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <Money />
                        </el-icon>
                        余额
                    </div>
                </template>

                <el-skeleton animated :loading="loading" style="height:22px">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>
                        ￥{{ balance }} <el-tag effect="plain" type="warning" size="small" checked>充值</el-tag>
                    </template>
                </el-skeleton>
  
            </el-descriptions-item>

            <el-descriptions-item>
                <template #label>
                    <div class="cell-item">
                        <el-icon :style="iconStyle">
                            <location />
                        </el-icon>
                        地址
                    </div>
                </template>

                <el-skeleton animated :loading="loading" style="height:22px; width:350px;">
                    <template #template>
                        <el-skeleton-item variant="text" style="height:22px"/>
                    </template>
                    <template #default>
                        江苏省南京市浦口区，南京工业大学浦珠南路30号
                    </template>
                </el-skeleton> 
            </el-descriptions-item>

        </el-descriptions>


        <el-dialog v-model="editVisible" title="修改信息" width="30%" center draggable destroy-on-close>
            <el-form :model="form" ref="refDeviceForm">
                <el-form-item label="用户头像">
                    <el-input v-model.avatar="form.avatar" />
                </el-form-item>
                <el-form-item label="用户名称">
                    <el-input v-model="form.name" />
                </el-form-item>
                <el-form-item label="邮箱地址">
                    <el-input v-model="form.email" />
                </el-form-item>
                <el-form-item label="联系方式">
                    <el-input v-model="form.tellphone" />
                </el-form-item>
                <el-form-item label="单位组织">
                    <el-input v-model="form.organization" />
                </el-form-item>
                <el-form-item label="以太地址">
                    <el-input v-model="form.addres" disabled />
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="editVisible = false">取消</el-button>
                    <el-button type="primary" @click="handleSubmit">确定</el-button>
                </span>
            </template>
        </el-dialog>

    </div>
</template>
  
<style scoped>
.container {
    display: grid;
    justify-content: center;
    align-items: center;
}

.avtar {
    margin-top: 33px;
}

.el-descriptions {
    margin-top: 20px;
    width: 476px;
}

.cell-item {
    display: flex;
    align-items: center;
}



.my-label {
    background: var(--el-color-success-light-9);
}

.my-content {
    background: var(--el-color-danger-light-9);
}
</style>
  