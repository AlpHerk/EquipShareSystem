<script  lang="ts" setup>
import { computed, ref, reactive, onMounted, markRaw } from 'vue'
import { Search, Upload, CirclePlus, Phone, MapLocation, SetUp, PriceTag, Coin } from '@element-plus/icons-vue' 
import { addEquipment, freezeEquipment, unfreezeEquipment, createLeasePact } from '@/hooks/useWeb3'
import { ElMessage, ElMessageBox } from 'element-plus'
import { type Equipment } from '@/stores/datatype'
import { Lock } from '@element-plus/icons-vue'
import { useEquipmentStore } from '@/stores/equipmentStore'
import { useLeasePactStore } from '@/stores/leasePactStore'

onMounted( async () => {
        store.allEquipment() 
    }
)

const store  = useEquipmentStore()

const search = ref('')

const filterTableData = computed(() =>  

    store.equipmentAll.filter((data) => !search.value
    || data.id!!.toLowerCase().includes(search.value.toLowerCase())
    || data.name.toLowerCase().includes(search.value.toLowerCase())
    || data.category.toLowerCase().includes(search.value.toLowerCase()))
 )

const newIndex = ref(-1)

const handleAdd = async () => {
    addEquipFormVisible.value = true
    newIndex.value = -1
    for (let key in addEquipForm) {
        addEquipForm[key] = ""
    }
}

const equipment = ref({} as Equipment)

const timeFormVisible = ref(false)

const timeRange = ref([new Date(), new Date()])
const timeRangeHour = computed(() => { 
    if (timeRange.value[0]) {
        return Math.floor((timeRange.value[1].getTime() - timeRange.value[0].getTime()) / (60*60*1000))
    } else {
        return 0
    }
})

const handleReserve = async (row: Equipment) => {
    timeFormVisible.value = true 
    equipment.value = row
}

const handleReserveSubmit = async () => {
    const res = await createLeasePact(
        equipment.value!.id,
        Math.floor(timeRange.value[0].getTime() / 1000),
        Math.floor(timeRange.value[1].getTime() / 1000)
    )
    timeFormVisible.value = false
    const store2 = useLeasePactStore()
    store2.ownedLeasePact()
    if (res) {
        ElMessage.success("预约成功")
    }
}


const handleMoreDetails = (index: number, row: Equipment) => {
    titleStr.value = "详细设备信息"
    addEquipFormVisible.value = true
    addEquipForm = row
}
 

const handleFreezeOrNot = (row: Equipment) => { 

    if (!row.isFrozen) {  
        ElMessageBox.confirm("确定要【冻结】该设备吗？", '提示',
        { type: 'error', cancelButtonText: '取消', confirmButtonText: '确定', icon: markRaw(Lock) })
        .then(async () => { 
            if (await freezeEquipment(row.id)) {
                row.isFrozen = true
                ElMessage.info("冻结完成")
            } 
        })
    } else {
        ElMessageBox.confirm("确定要【解冻】该设备吗？", '提示',
        { type: 'success', cancelButtonText: '取消', confirmButtonText: '确定', icon: markRaw(Lock) })
        .then(async () => {  
            if (await unfreezeEquipment(row.id) ) {
                row.isFrozen = false 
                ElMessage.success("解冻成功")
            } 
        })
    }

} 

// 对话框相关 ///////////////////////////////////////////////////////////
const addEquipFormVisible = ref(false)
const titleStr = ref("添加新设备")


// 对话框中的表单数据 
let addEquipForm: Equipment = reactive({
    name: "",
    owner: "",
    category: "",
    createdTime: "",
    descLink: "",
    imagesLink: "",
    unitPrice: "",
    deposit: ""
})


// 对话框：确认函数
const handleAddEquipSubmit = async () => {
    addEquipFormVisible.value = false
    await addEquipment(addEquipForm)
}

const shortcuts = [
    {
        text: '下一小时',
        value: () => {
            const start = new Date()
            const end = new Date()
            end.setTime(start.getTime() + 3600 * 1000)
            return [start, end]
        },
    },
    {
        text: '今天整天',
        value: () => {
            const now = new Date()
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

            const end = new Date()
            end.setTime(today.getTime() + 3600 * 1000 * 24)
            return [today, end]
        },
    },
    {
        text: '明天整天',
        value: () => {
            const now = new Date()
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

            const start = new Date()
            const end = new Date()
            start.setTime(today.getTime() + 3600 * 1000 * 24)
            end.setTime(today.getTime() + 3600 * 1000 * 24 * 2)
            return [start, end]
        },
    }
]



</script>

 
<template>
    <el-row>
        <el-col :span="4">
            <el-input v-model="search" size="small" placeholder="输入搜索内容" style="padding-right: 20px;"> </el-input>
        </el-col>
        <el-button size="small" :icon="Search" type="success">查询</el-button>

        <el-button size="small" :icon="CirclePlus" type="primary" @click="handleAdd">新增</el-button>
        <el-button size="small" :icon="Upload" type="primary" @click="handleAdd">上传</el-button>

    </el-row>
    <div>
        <el-table :data="filterTableData" style="width: 100%">
            <el-table-column label="设备编号" prop="id"/>
            <el-table-column label="设备图片" prop="imagesLink"/>
            <el-table-column label="设备名称" prop="name" min-width="200"/>
            <el-table-column label="描述信息" prop="descLink" min-width="200"/>
            <el-table-column align="right" fixed="right" width="200">
                <template #header>
                    <el-row> 
                        <el-input v-model="search" size="small" placeholder="输入搜索内容"> </el-input>

                    </el-row>
                </template>

                <template #default="scope">
                    <el-button plain size="small" type="primary"
                        @click="handleReserve(scope.row)">预约</el-button>
                    <el-button plain size="small" type="warning"
                        @click="handleMoreDetails(scope.$index, scope.row)">详情</el-button>
                    <el-button plain size="small" :type='scope.row.isFrozen ? "info" : "danger"'
                        @click.prevent="handleFreezeOrNot(scope.row)">{{scope.row.isFrozen ? "解冻" : "冻结"}}</el-button>
                </template>

            </el-table-column>
        </el-table>
    </div>

    <el-dialog v-model="addEquipFormVisible" :title="titleStr" width="30%" center draggable destroy-on-close>
        <el-form :model="addEquipForm">
            <el-form-item label="设备名称">
                <el-input v-model="addEquipForm.name" />
            </el-form-item>

            <el-form-item label="设备类型">
                <el-input v-model="addEquipForm.category" />
            </el-form-item>
            <el-form-item label="描述信息">
                <el-input v-model="addEquipForm.descLink" />
            </el-form-item>
            <el-form-item label="图片展示">
                <el-input v-model="addEquipForm.imagesLink" />
            </el-form-item>
            <el-form-item label="联系人">
                <el-input v-model="addEquipForm.owner" />
            </el-form-item>
            <el-form-item label="单价">
                <el-input v-model.id="addEquipForm.unitPrice" />
            </el-form-item>
            <el-form-item label="押金">
                <el-input v-model.id="addEquipForm.deposit" />
            </el-form-item>

        </el-form>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="addEquipFormVisible = false">取消</el-button>
                <el-button type="primary" @click="handleAddEquipSubmit">确定</el-button>
            </span>
        </template>
    </el-dialog>

    <el-dialog v-model="timeFormVisible" title="预约设备" width="30%" center draggable>

        <el-date-picker v-model="timeRange" :shortcuts="shortcuts" type="datetimerange" 
        range-separator="To" start-placeholder="开始时间" end-placeholder="结束时间" style="width: 100%;margin-bottom: 20px;padding-right: 0px;"/>

        <div class="reserveTab">
            <el-row class="reserveTabItem">
                <el-col :span="4"><el-icon><SetUp/></el-icon>设备</el-col>
                <el-col :span="2">:</el-col>
                <el-col :span="18">{{ equipment.name }}</el-col>
            </el-row>
            <el-row class="reserveTabItem">
                <el-col :span="4"><el-icon><Phone/></el-icon>联系</el-col>
                <el-col :span="2">:</el-col>
                <el-col :span="18">埃德米老师（{{ equipment.owner.slice(0, 8) + "..." + equipment.owner.slice(-4) }}）</el-col>
            </el-row>
            <el-row class="reserveTabItem">
                <el-col :span="4"><el-icon><MapLocation/></el-icon>地址</el-col>
                <el-col :span="2">:</el-col>
                <el-col :span="18">南京工业大学江浦校区</el-col>
            </el-row>
            <el-row class="reserveTabItem">
                <el-col :span="4"><el-icon><PriceTag/></el-icon>租金</el-col>
                <el-col :span="2">:</el-col>
                <el-col :span="18">{{ equipment.unitPrice }} * {{ timeRangeHour }}H = {{ Number(equipment.unitPrice) * timeRangeHour }} （ 押金 {{ Number(equipment.deposit)}} ） </el-col>
            </el-row>
            <el-row class="reserveTabItem" style="color:brown">
                <el-col :span="4"><el-icon><Coin /></el-icon>总计</el-col>
                <el-col :span="2">:</el-col>
                <el-col :span="18">￥{{ Number(equipment.unitPrice) * timeRangeHour + Number(equipment.deposit) }} </el-col>
            </el-row>
        </div>
        <template #footer>
            <span class="dialog-footer">
                <el-button @click="timeFormVisible = false">取消</el-button>
                <el-button type="primary" @click="handleReserveSubmit">确定</el-button>
            </span>
        </template>

    </el-dialog>

</template>
     
 
<style lang="scss">
.reserveTab {
    width: 100%;
    overflow: hidden;
    .reserveTabItem {
        padding: 10px 9px;
        .el-icon{
            padding-right: 10px;
        }
    }
}
</style>