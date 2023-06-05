<script setup lang="ts">
import { ref, onMounted } from 'vue' 
import ReserveHistory from './ReserveHistory.vue'
import ReserveReview from './ReserveReview.vue'
import RequestReturn from './RequestReturn.vue'  
import { useLeasePactStore } from '@/stores/leasePactStore'
const store = useLeasePactStore()
const activeName = ref('first')  
onMounted(async () => { 
        store.ownedLeasePact()    
    }
)
</script> 

<template> 

    <el-tabs v-model="activeName">
        <el-tab-pane label="预约审核" name="first"><ReserveReview/></el-tab-pane>
        <el-tab-pane label="催收设备" name="second"><RequestReturn/></el-tab-pane> 
        <el-tab-pane label="历史记录" name="third"><ReserveHistory/></el-tab-pane>
    </el-tabs>

</template>
    

    