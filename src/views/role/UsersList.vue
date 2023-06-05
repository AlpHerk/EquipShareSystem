<script setup lang="ts">
import { computed, ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus';
 
import { addUser, updateUser, getUserAll } from '@/hooks/useWeb3';
import { Search, Upload, CirclePlus } from '@element-plus/icons-vue'
import { type User } from '@/stores/datatype'
import { useUserStore } from '@/stores/userStore'


const store = useUserStore()
const search = ref('')
const editVisible = ref(false)
const titleStr = ref("添加用户")

// 表格数据相关 //////////////////   
const filterTableData = computed(() => 
    store.userAll.filter(
        (data) => !search.value
        || data.id!.toLowerCase().includes(search.value.toLowerCase())
        || data.name.toLowerCase().includes(search.value.toLowerCase())
        || data.organization.toLowerCase().includes(search.value.toLowerCase())
    )
)

const handleAdd = async () => {
    titleStr.value = "添加用户"
    editVisible.value = true
    newIndex = -1 // 赋值为 -1 表示添加了条目
    
    for (let key in form) {
        form[key] = ""
    }
}


// 编辑用户条目
let newIndex: number = -1;
const handleEdit = (index: number, row: User) => {
    console.log(index);
    
    titleStr.value = "修改信息"
    editVisible.value = true
    newIndex = index
    form.addres = row.addres
    form.id = row.id
    form.name = row.name
    form.avatar = row.avatar
    form.email = row.email
    form.tellphone = row.tellphone
    form.organization = row.organization
}

// 查看用户详情
const handleCheck = async (index: number, row: User) => {
    // const userinfo = store.userAll[index]
    titleStr.value = "详细信息"
    editVisible.value = true 
    newIndex = -2
    form.addres = row.addres
    form.id = row.id
    form.name = row.name
    form.avatar = row.avatar
    form.email = row.email
    form.tellphone = row.tellphone
    form.organization = row.organization
    // await getEquipment(row.id)
    // TODO 处理抓取的用户信息，以生成详情
}

 
// 对话框中的表单数据 
let form: User = reactive({
    name: "",
    avatar: "",
    email: "",
    tellphone: "",
    organization: "",
    addres: ""
})
 

// 对话框：确认函数
const handleSubmit = async () => {
    editVisible.value = false
    // 如若则添加条目,否则编辑条目
    if (newIndex == -1) {
        if (form.addres) {
            if (await addUser(form)) {
                ElMessage.success(`用户添加成功`)
            }
        } else {
            ElMessage.warning(`添加失败，以太坊地址无效`)
        }
    } else if (newIndex >= 0) {
        ElMessageBox.confirm('确定要修改吗？', '提示', { type: 'warning', cancelButtonText: '取消', confirmButtonText: '确定' })
        .then(async () => { 
            if (await updateUser(form)) {
                store.userAll[newIndex] = form
                ElMessage.success(`第 ${newIndex + 1} 行：用户 ${form.name} 信息修改成功`)
            } else {
                ElMessage.warning(`第 ${newIndex + 1} 行：用户 ${form.name} 信息修改失败`)
            }
        })
    }
}
 


</script>



<template>
    <el-row>
        <el-col :span="4">
            <el-input v-model="search" size="small" placeholder="输入搜索内容" style="padding-right: 20px;"> </el-input>
        </el-col>
        <el-button size="small" :icon="Search" type="success">查询</el-button>
        <el-button size="small" :icon="CirclePlus" type="primary" @click="handleAdd">新增</el-button>
        <el-button size="small" :icon="Upload" type="primary" >上传</el-button>


    </el-row>
    <el-table :data="filterTableData" style="width: 100%">
        <el-table-column label="用户 ID" prop="id" />
        <el-table-column label="用户名称" prop="name" />
        <el-table-column label="联系方式" prop="tellphone" />
        <el-table-column label="邮箱地址" prop="email" />
        <el-table-column label="单位组织" prop="organization" /> 
        <el-table-column fixed="right" label="操作">

            <template #default="scope">
                <el-button plain size="small" type="warning" @click="handleEdit(scope.$index, scope.row)">修改</el-button>
                <el-button plain size="small" @click.prevent="handleCheck(scope.$index, scope.row)">详情</el-button>
            </template>
        </el-table-column>
    </el-table>

    <el-dialog v-model="editVisible" :title="titleStr" width="30%" center draggable destroy-on-close>
        <el-form :model="form" ref="refDeviceForm">
            <!-- <el-form-item label="用户头像">
                <el-input v-model.avatar="form.avatar" autocomplete="off" />
            </el-form-item> -->
            <el-form-item label="用户名称">
                <el-input v-model="form.name" autocomplete="off" />
            </el-form-item>
            <el-form-item label="邮箱地址">
                <el-input v-model="form.email" autocomplete="off" />
            </el-form-item>
            <el-form-item label="联系方式">
                <el-input v-model="form.tellphone" autocomplete="off" />
            </el-form-item>
            <el-form-item label="单位组织">
                <el-input v-model="form.organization" autocomplete="off" />
            </el-form-item>
            <el-form-item label="以太地址" v-show="newIndex<0">
                <el-input v-model="form.addres" autocomplete="off"/>
            </el-form-item>
        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="editVisible = false">取消</el-button>
                <el-button type="primary" @click="handleSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>

    
</template>
     
 
<style scoped>
.el-pagination {
    display: flex;
    justify-content: center;
}
</style>