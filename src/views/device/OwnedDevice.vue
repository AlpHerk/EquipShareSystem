<script  lang="ts" setup>
import { computed, ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OccupyType, type Equipment } from '@/stores/datatype'
import { addEquipment, updateEquipment, removeEquipment, maintainEquipment, endMaintainEquipment } from '@/hooks/useWeb3'
import { useEquipmentStore } from '@/stores/equipmentStore'
 
onMounted( async () => { 
        store.ownedEquipment()  
    }
)

const store = useEquipmentStore()


const search = ref('') 
  

const filterTableData = computed(() =>
    store.equipmentOwned.filter((data) => !search.value 
    || data.id.toLowerCase().includes(search.value.toLowerCase())
    || data.name.toLowerCase().includes(search.value.toLowerCase())
    || data.category.toLowerCase().includes(search.value.toLowerCase()))
)

const handleAdd = async () => {
    editVisible.value = true
    dialogTitle = "添加新设备"
    newIndex = -1 // 赋值为 -1 表示添加了条目 

    for (const key in form) {
        form[key] = ""
    }
}
 
const equipment = ref<Equipment>({
    name: "",
    category: "",
    descLink: "",
    imagesLink: "",
    unitPrice: "",
    deposit: "" 
})

const timeFormVisible = ref(false)

const timeRange = ref([new Date(), new Date()])

const equiptStatusTag = computed(() => {
    return (equipment: Equipment) => { 
        const occupytype = equipment.occupytype
        if (occupytype == OccupyType.OPEN) {
            return ["空闲", "success"]
        } else if (occupytype == OccupyType.MAINTAIN) {
            return ["维护", "warning"] 
        } else if (occupytype == OccupyType.FROZEN) {
            return ["冻结", "danger" ] 
        } else if (occupytype == OccupyType.LENT) {
            return ["占用", ""       ]
        } else {
            return ["占用", ""       ]
        }
    }
})

const maintainButtonText = computed(()=> {
    return (equipment: Equipment) => { 
        const occupytype = equipment.occupytype
        if (occupytype == OccupyType.OPEN) { 
            return ["维修", "warning"]
        } else if (occupytype == OccupyType.MAINTAIN) {
            return ["解除", "success"]
        } else if (occupytype == OccupyType.LENT) {
            return ["催收", "primary"] 
        } else if (occupytype == OccupyType.FROZEN) {
            return ["申诉", "danger"]
        } else {
            return ["维修", "warning"]
        }
    }
})

const handleOperate = async (index:number, row: Equipment) => {
    const occupytype = store.equipmentOwned[index].occupytype
    if (occupytype == OccupyType.OPEN) {
        // 若设备处于空闲状态，则显示维修按钮，并唤起维修窗口
        newIndex = index
        equipment.value = row 
        timeFormVisible.value = true
    } else if (occupytype == OccupyType.LENT) {
        // 若设备处于出租状态，则显示催收按钮 
    } else if (occupytype == OccupyType.MAINTAIN) {
        // 若设备处于维修状态，则显示解除按钮
        store.equipmentOwned[index].occupytype = OccupyType.OPEN
        if (await endMaintainEquipment(store.equipmentOwned[index].id)) {
            ElMessage.success("设备维修解除，届时恢复使用") 
        }
    } else if (occupytype == OccupyType.FROZEN) {
        // 申诉按钮，申请解冻
    }
    
}
 
const handleMaintainSubmit = async ()  => {  
    if (equipment.value.occupytype == OccupyType.OPEN) {
        const start = Math.floor(timeRange.value[0].getTime()/1000)
        const end = Math.floor(timeRange.value[1].getTime()/1000)
        store.equipmentOwned[newIndex].occupytype = OccupyType.MAINTAIN

        if (await maintainEquipment(equipment.value.id, start, end)) {
            ElMessage.warning("设备已预约维修，届时暂停使用") 
        }
    } else {
        ElMessage.warning("所选时段占用中，请于空闲时段维修") 
    }
    timeFormVisible.value = false
}

// 编辑设备条目
let newIndex: number = 0
let dialogTitle: string
const handleEdit = (index:number, row: Equipment) => {
    editVisible.value = true
    dialogTitle = "修改设备信息"
    newIndex = index
    for (let i in row) {
        form[i] = row[i]
    } 
}

// 删除设备条目
const handleDelete = (index: number, row: Equipment) => {
    ElMessageBox.confirm('确定要删除吗？', '提示', { type: 'warning', cancelButtonText: '取消', confirmButtonText: '确定' })
        .then(async () => { 
            if (await removeEquipment(row.id)) {
                newIndex = index
                store.equipmentOwned.splice(index, 1)
                ElMessage.success(`设备 ${row.id} 删除成功`)
            }
        })
}


// 对话框相关 ///////////////////////////////////////////////////////////
const editVisible = ref(false)
// 对话框中的表单数据 
let form: Equipment = reactive({
    name: "",
    category: "",
    descLink: "",
    imagesLink: "",
    unitPrice: "",
    deposit: "" 
})


// 对话框：确认函数
const handleSubmit = async () => {
    editVisible.value = false
    // 如若则添加条目,否则编辑条目
    if (newIndex == -1) {
        if (await addEquipment(form)) {
            ElMessage.success(`设备 ${form.name} ：添加成功`)
        }
    } else { 
        ElMessageBox.confirm('确定要修改吗？', '提示', { type: 'warning', cancelButtonText: '取消', confirmButtonText: '确定' })
            .then(async () => {
                if (await updateEquipment(form)) {
                    store.equipmentOwned[newIndex] = form
                    ElMessage.success(`设备 ${form.id} ：修改信息成功`)
                } else {
                    ElMessage.warning(`设备 ${form.id} ：修改信息失败`)
                }
            }) 
    }
}

// 对话框：取消函数
const handleCancel = () => {
    editVisible.value = false
}





</script>


<template>
    <div>
        <el-table :data="filterTableData" style="width: 100%">
            <el-table-column label="设备图片" prop="imagesLink"/>
            <el-table-column label="设备名称" prop="name" min-width="200"/>
            <el-table-column label="设备编号" prop="id" />
            <el-table-column label="描述信息" prop="descLink" min-width="200"/>
            <el-table-column label="设备状态" prop="tag">
                <template #default="scope">
                    <el-tag :type="equiptStatusTag(scope.row)[1]">{{ equiptStatusTag(scope.row)[0]
                    }}</el-tag>
                </template>
            </el-table-column>

            <el-table-column align="right" fixed="right"  width="200">
                <template #header>
                    <el-row>
                        <el-col :span="16">
                            <el-input v-model="search" size="small" placeholder="输入搜索内容"> </el-input>
                        </el-col>
                        <el-col :span="8">
                            <el-button size="small" type="success" @click="handleAdd">新增</el-button>
                        </el-col>

                    </el-row>
                </template>

                <template #default="scope">
                    <el-button plain size="small" :type="maintainButtonText(scope.row)[1]" @click="handleOperate(scope.$index, scope.row)">{{maintainButtonText(scope.row)[0]}}</el-button>
                    <el-button plain size="small" type="warning" @click="handleEdit(scope.$index, scope.row)">修改</el-button>
                    <el-button plain size="small" type="danger"
                        @click.prevent="handleDelete(scope.$index, scope.row)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
    </div>

    <el-dialog v-model="editVisible" :title="dialogTitle" width="30%" center draggable destroy-on-close>
        <el-form :model="form" ref="refDeviceForm">
            <el-form-item label="设备名称">
                <el-input v-model="form.name" />
            </el-form-item>
            <el-form-item label="设备类型">
                <el-input v-model="form.category" />
            </el-form-item>
            <el-form-item label="描述信息">
                <el-input v-model="form.descLink" />
            </el-form-item>
            <el-form-item label="图片展示">
                <el-input v-model="form.imagesLink" />
            </el-form-item>
            <el-form-item label="单价">
                <el-input v-model="form.unitPrice" />
            </el-form-item>
            <el-form-item label="押金">
                <el-input v-model="form.deposit" />
            </el-form-item>
        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="handleCancel">取消</el-button>
                <el-button type="primary" @click="handleSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>

    <el-dialog v-model="timeFormVisible" title="维修时段" width="30%" center draggable>
        <el-date-picker v-model="timeRange" type="datetimerange" range-separator="To"
            start-placeholder="开始时间" end-placeholder="结束时间" style="width:100%; padding-right: 0px;"/>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="timeFormVisible = false">取消</el-button>
                <el-button type="primary" @click="handleMaintainSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>

</template>
     
 
    