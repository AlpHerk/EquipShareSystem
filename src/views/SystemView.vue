<script lang="ts">
export default {
    data() {
        return {
            form: {
                name: '',
                region: '',
                date1: '',
                date2: '',
                delivery: false,
                type: [],
                resource: '',
                desc: '',
            },
            activities: [
                {
                    content: '采购申请',
                    timestamp: '2018-04-12 20:46',
                    size: 'large',
                    type: 'primary',
                    icon: 'el-icon-more',
                },
                {
                    content: '招标审核',
                    timestamp: '2018-04-03 20:46',
                    color: '#0bbd87',
                },
                {
                    content: '合同登记',
                    timestamp: '2018-04-03 20:46',
                    type: 'primary',
                    hollow: true,
                },
                {
                    content: '历史查询',
                    timestamp: '2018-04-03 20:46',
                },
            ],
        }
    },
    methods: {
        onSubmit() {
            console.log('submit!')
        },
    },
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


        <el-form-item label="采购管理">
            <el-checkbox-group v-model="form.type">
                <el-checkbox label="采购申请" name="type"></el-checkbox>
                <el-checkbox label="采购审核" name="type"></el-checkbox>
                <el-checkbox label="合同登记" name="type"></el-checkbox>
                <el-checkbox label="采购查询" name="type"></el-checkbox>
                <el-checkbox label="报表打印" name="type"></el-checkbox>
                <el-checkbox label="用户管理" name="type"></el-checkbox>
            </el-checkbox-group>
        </el-form-item>



        <div direction="horizon" style="margin-left: 0px;">
            <el-timeline>
                <el-timeline-item 
                v-for="(activity, index) in activities" 
                :key="index" 
                :icon="activity.icon"
                :type="activity.type" 
                :color="activity.color" 
                :size="activity.size" 
                :hollow="activity.hollow"
                :timestamp="activity.timestamp">
                    {{ activity.content }}
                </el-timeline-item>
            </el-timeline>
        </div>
 
        <el-form-item label="备注信息">
            <el-input type="textarea" v-model="form.desc"></el-input>
        </el-form-item>
        <el-form-item>
            <el-button type="primary" @click="onSubmit">立即提交</el-button>
            <el-button>取消</el-button>
        </el-form-item>
    </el-form>
</template>
     