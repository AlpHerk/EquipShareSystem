<script  lang="ts" setup>
import { computed, ref, reactive, onMounted } from 'vue' 
import { ElMessage, ElMessageBox } from 'element-plus';
import { poposeEndLeasePact } from '@/hooks/useWeb3';  
import { useLeasePactStore } from '@/stores/leasePactStore' 
import { type Equipment } from '@/stores/datatype'

onMounted(async()=>{ 
    store.rentedLeasePact()
})
  
const store = useLeasePactStore()

const search = ref('') 

// 获取表格数据：注意此处赋值需要用　reactive　 

const filterTableData = computed(() =>
    store.approvedLeasePacts.filter((data) => !search.value
    || data.id.toLowerCase().includes(search.value.toLowerCase())
    || data.equipmentName.toLowerCase().includes(search.value.toLowerCase()) )
)
 


// 编辑设备条目
const handleRenew = (index: number, row: Equipment) => {
	editVisible.value = true
 
}

const handleReturn = (index: number, row: Equipment) => {
    ElMessageBox.confirm('确定归还设备？', '提示', 
    {type: 'warning', cancelButtonText: '取消', confirmButtonText: '确定'})
    .then(async () => {
        if (await poposeEndLeasePact(row.id)) {
            ElMessage.success('归还成功')
	        store.approvedLeasePacts.splice(index, 1)
        } 
	})
}


// 对话框相关 ///////////////////////////////////////////////////////////
const editVisible = ref(false)
// 对话框中的表单数据 
let form: Equipment = reactive({
    id  : "",
    name: "",
    owner: "",
    category: "",
    createdTime: "",
    descLink:   "",
    imagesLink: "",
    unitPrice:  "",
    deposit:    ""
})
 

// 对话框：确认函数
const handleSubmit = async () => {
    editVisible.value = false 
}

// 对话框：取消函数
const handleCancel = () => {
    editVisible.value = false  
}
const timeStamp = (time: number) => {
 const date = new Date(time * 1000)

 const hours = date.getHours() < 9 ? `0${date.getHours()}` : date.getHours()
 const minutes = date.getMinutes() < 9 ? `0${date.getMinutes()}` : date.getMinutes()

 const formattedDate1 = `
     ${date.getFullYear()}/${date.getMonth()+1}/${date.getDate()} ${hours}:${minutes}
 `
 return formattedDate1
}
</script>

 
<template>
    <div>
        <el-table :data="filterTableData" style="width: 100%"> 
            <el-table-column label="合同编号" prop="id" />
            <el-table-column label="设备名称" prop="equipmentName" min-width="200"/>
            <el-table-column label="设备持有人" prop="renterName" />
            <el-table-column label="开始时间" prop="time" min-width="100">
                <template #default="scope">
                    {{timeStamp(scope.row.period[0])}}
                </template>
            </el-table-column>
            <el-table-column label="结束时间" prop="time" min-width="100">
                <template #default="scope">
                    {{timeStamp(scope.row.period[1])}}
                </template>
            </el-table-column>

            <el-table-column align="right" fixed="right" width="200">
                <template #header>
                    <el-input v-model="search" size="small" placeholder="输入搜索内容"> </el-input>

                </template>

                <template #default="scope">
                    <el-button plain size="small" type="primary" @click="handleRenew(scope.$index, scope.row)">续约</el-button>
                    <el-button plain size="small" type="warning"
                        @click.prevent="handleReturn(scope.$index, scope.row)">归还</el-button>
                </template>
            </el-table-column>
        </el-table>
    </div>

    <el-dialog v-model="editVisible" title="添加新设备" width="30%" center draggable destroy-on-close>
        <el-form :model="form" ref="refDeviceForm">
            <el-form-item label="设备名称">
                <el-input v-model="form.name" autocomplete="off" />
            </el-form-item>
            <el-form-item label="设备类型">
                <el-input v-model="form.category" autocomplete="off" />
            </el-form-item>
            <el-form-item label="描述信息">
                <el-input v-model="form.descLink" autocomplete="off" />
            </el-form-item>
            <el-form-item label="图片展示">
                <el-input v-model="form.imagesLink" autocomplete="off" />
            </el-form-item>
            <el-form-item label="单价">
                <el-input v-model.id="form.unitPrice" autocomplete="off" />
            </el-form-item>
            <el-form-item label="押金">
                <el-input v-model.id="form.deposit" autocomplete="off" />
            </el-form-item>
        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="handleCancel">取消</el-button>
                <el-button type="primary" @click="handleSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>
</template>
     
 
    