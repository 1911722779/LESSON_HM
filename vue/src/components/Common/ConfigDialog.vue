<template>
  <el-dialog
    v-model="dialogVisible"
    :width="isMobile() ? '100%' : '500px'"
    cente
    title="修改后台接口地址"
  >
    <el-form ref="formRef" :model="form" label-width="120px" size="large">
      <el-form-item
        :rules="[
          { required: true, message: '请输入接口地址', trigger: 'blur' },
        ]"
        label="后台接口地址"
        prop="baseUrl"
      >
        <el-input
          v-model="form.baseUrl"
          placeholder="请输入接口地址"
        ></el-input>
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="dialogVisible = false">取消</el-button>
      <el-button type="primary" @click="submitForm">保存</el-button>
    </template>
  </el-dialog>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { httpClient } from '@/utils/http.ts'
import { isMobile } from '@/utils/index.ts'

const props = defineProps<{
  modelValue: boolean
}>()

const formRef = ref(null)
const form = ref({
  baseUrl: httpClient.defaults.baseURL || '',
})

const emit = defineEmits(['update:modelValue'])

const dialogVisible = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value),
})

function submitForm() {
  formRef.value.validate((valid) => {
    if (valid) {
      // 动态修改axios baseURL
      httpClient.defaults.baseURL = form.value.baseUrl
      dialogVisible.value = false
      ElMessage.success('接口地址已更新: ' + form.value.baseUrl)
    }
  })
}
</script>
