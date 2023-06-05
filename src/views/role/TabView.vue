<script lang="ts" setup >
import RoleList from './UsersList.vue'
import { ref, onMounted,  onBeforeMount } from 'vue';
import { useUserStore } from '@/stores/userStore'

const store = useUserStore()

onBeforeMount(async () => { 
        store.allUser()
    }
)

const activeName = ref('first') 
const handleClick = (tab, event) => { 
}

</script>
<template>
    <el-tabs v-model="activeName" @tab-click="handleClick">
        <el-tab-pane label="用户列表" name="first">
            <RoleList></RoleList>
        </el-tab-pane>
        <el-tab-pane label="角色分组" name="second"></el-tab-pane>
        <el-tab-pane label="权限分配" name="third"></el-tab-pane>
    </el-tabs>
</template>
    
<style scoped></style>