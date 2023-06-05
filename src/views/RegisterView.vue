<script setup lang="ts">

import { reactive, ref } from "vue"
import { createAccount } from "@/hooks/account" 
  
let form = reactive({
    name:   "",
    avatar: "",
    email:  "",
    tellphone:    "",
    organization: "",
    
    address:   "",
    passward:  "",
    passward2: "",
    keystore:  ""
})


const onRegister = () => {
    const account = createAccount(form.passward)
}

</script>

<template>
    <div class="login_wrap">

        <div class="form_wrap">
            <el-form label-width="100px" :model="form" style="width: 300px">

                <el-form-item label="用户名称">
                    <el-input v-model="form.name" placeholder="用户名称" />
                </el-form-item>
                <el-form-item label="用户密码">
                    <el-input v-model="form.passward" type="password" show-password placeholder="用户密码" />
                </el-form-item>
                <el-form-item label="确认密码">
                    <el-input v-model="form.passward2" type="password" show-password placeholder="确认密码" />
                </el-form-item> 


                <el-form-item>
                    <el-button type="primary" @click="onRegister">注册账号</el-button>
                </el-form-item>
            </el-form>
        </div>

    </div>
</template>

<style>
.login_wrap {
    width: 100%;
    height: 100vh;
    position: relative;
    background-color: #b0d5ff;

}

.form_wrap {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
</style>
