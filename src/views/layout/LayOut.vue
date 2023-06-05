<script lang="ts" setup>
import { RouterView } from 'vue-router'
import MenuAside from './MenuAside.vue'
import MenuTop from './MenuTop.vue'
</script>


<template>
    <div class="common-layout">
        <el-container>
            <el-aside class="common-aside" width="200px">
                <MenuAside></MenuAside>
            </el-aside>


            <el-container>
                <el-header class="common-header flex-float">
                    <div class="flex">
                        <h1 class="title">高校大型仪器设备共享系统</h1>
                    </div>
                    <MenuTop></MenuTop>
                </el-header>

                <el-container>
                    <el-main class="main_router_view">
                        <RouterView />
                    </el-main>
                </el-container>

            </el-container>
        </el-container>
    </div>
</template>

<style scoped lang="scss">
.el-container {
    height: 100vh;
    overflow: hidden;
} 

.main_router_view:has(.notice_view) {
    padding: 0;
}

.common-header {
    background: $color_menutop; 
    display: flex;
    box-shadow: 0px 5px  10px #c6cbd1;
}

.common-aside {
    background: $color_memuside; 
}
  
.title {
    /* color: #39ace6; */
    color: $color_primary;
}
</style>
  