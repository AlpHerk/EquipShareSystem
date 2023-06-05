<script lang="ts" setup>

import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router' 


let formLabelAlign = reactive({
  username: '',
  password: '',
  isremember: false,
})

let router = useRouter() 

async function onLogin() {
  // 请求用户授权连接以太坊账户
  // const accounts = await web3.eth.requestAccounts();
 
  // const account = web3.eth.accounts.privateKeyToAccount(privatekey);
 

  // router.push('/home')
 
  
}
 
</script>

<template>
  
  <div class="login_wrap">

    <div class="form_wrap">
      <el-form label-width="100px" :model="formLabelAlign" style="max-width: 460px">
        <el-form-item label="用户地址">
          <el-input v-model="formLabelAlign.username" />
        </el-form-item>
        <el-form-item label="用户密码">
          <el-input v-model="formLabelAlign.password" />
        </el-form-item>
        <el-form-item label="记住密码">
          <el-checkbox v-model="formLabelAlign.isremember" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onLogin">登录</el-button>
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
  background-color:#b0d5ff;

}

.form_wrap {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
</style>
