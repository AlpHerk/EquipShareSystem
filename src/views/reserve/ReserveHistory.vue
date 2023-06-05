<script  lang="ts" setup>
import { computed, ref, onMounted } from 'vue'  
import { useLeasePactStore } from '@/stores/leasePactStore';
import { type LeasePact } from '@/stores/datatype'

onMounted(async () => {  
        store.allLeasePact()
    }
)

const store = useLeasePactStore()
 
const search = ref('') 

const filterTableData = computed(() =>
    store.allLeasePacts.filter((data) => !search.value
    || data.id.toLowerCase().includes(search.value.toLowerCase())
    || data.equipmentId.toLowerCase().includes(search.value.toLowerCase()) 
    )
)
 

const handleDelete = (index: number, row: LeasePact) => {
     
} 

const timeRange = (row: LeasePact) => {
 
 const diffTime = Math.abs(row.period[1] - row.period[0])
 const diffHours = `${Math.floor(diffTime / (60 * 60))} H`
 
 return diffHours 
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
            <el-table-column label="合约编号" prop="id"/>
            <el-table-column label="设备名称"  prop="equipmentName" min-width="200"/> 
            <el-table-column label="借用人"  prop="renterName" min-width="100"/> 
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
            <el-table-column label="预约时长" prop="timeRange"  style="color:blue">
                <template #default="scope">
                    <el-tag>
                        {{timeRange(scope.row)}}
                    </el-tag>
                </template>
            </el-table-column>

            <el-table-column align="right" fixed="right" width="200">
                <template #header>  
                    <el-input v-model="search" size="small" placeholder="输入搜索内容"> </el-input> 
                </template>

                <template #default="scope">
                    <el-button plain size="small" type="success">正常</el-button> 
                </template>

            </el-table-column>
        </el-table>
    </div>


</template>
 