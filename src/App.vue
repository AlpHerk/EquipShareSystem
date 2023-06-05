<script setup lang="ts">
import { onMounted } from 'vue' 
import { importKeyStore } from '@/hooks/account' 

onMounted(async () => { 
    
	// Ganache 测试网私钥
    importKeyStore("0x611ea0f89b7a41e734b739f74a41d61ea2550cefba3e5db308046fa6ecac288d", "SetaPassWord12345678" )
  
})

</script>


<template>
	<RouterView />
</template>
 

<style>
body, html {
	padding: 0;
	margin: 0;
}

.flex-float {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.flex {
	display: flex;
	align-items: center;
}
</style>
