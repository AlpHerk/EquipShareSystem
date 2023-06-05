<script setup lang="ts">
import { reactive } from 'vue'

let form = reactive({
    name: '',
    region: '',
    date1: '',
    date2: '',
    delivery: false,
    type: [],
    resource: '',
    desc: '',
})
 
 
const onSubmit = () => {
    console.log('submit!')
}
  
</script> 


<template>
        <el-form ref="form" :model="form" label-width="100px">
        <el-row>
            <el-col :span="6">
                <el-form-item label="设备名称">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
            <el-col :span="6">
                <el-form-item label="使用部门">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
            <el-col :span="6">
                <el-form-item label="购置日期">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
            <el-col :span="6">
                <el-form-item label="保修日期">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
        </el-row>
        <el-row>
            <el-col :span="6">
                <el-form-item label="设备编号">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
            <el-col :span="6">
                <el-form-item label="型号规格">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
            <el-col :span="6">
                <el-form-item label="数量">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
            <el-col :span="6">
                <el-form-item label="金额">
                    <el-input v-model="form.name"></el-input>
                </el-form-item>
            </el-col>
        </el-row>
        <el-form-item label="资产类别">
            <el-select v-model="form.region" placeholder="请选择类别">
                <el-option label="设备" value="shanghai"></el-option>
                <el-option label="材料" value="beijing"></el-option>
            </el-select>
        </el-form-item>

        <el-form-item label="加急处理">
            <el-switch v-model="form.delivery"></el-switch>
        </el-form-item>
        <el-form-item label="设备用途">
            <el-checkbox-group v-model="form.type">
                <el-checkbox label="教学实验" name="type"></el-checkbox>
                <el-checkbox label="商用实验" name="type"></el-checkbox> 
                <el-checkbox label="其他原因" name="type"></el-checkbox>
            </el-checkbox-group>
        </el-form-item>

        <el-form-item label="备注信息">
            <el-input type="textarea" v-model="form.desc"></el-input>
        </el-form-item>
        <el-form-item>
            <el-button type="primary" @click="onSubmit">立即提交</el-button>
            <el-button>取消</el-button>
        </el-form-item>
    </el-form>
</template>

