<script setup lang="ts">
import { computed, ref } from 'vue'
// import LoginForm from './LoginForm.vue'
// import RegisterForm from './RegisterForm.vue'
// import ResetPasswordForm from './ResetPasswordForm.vue'
import { isMobile } from '@/utils'

const props = defineProps<{
  modelValue: boolean
}>()

const emit = defineEmits(['update:modelValue'])

const dialogVisible = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value),
})

const activeTab = ref('login')

const tabTitles = {
  login: '登录',
  register: '注册',
  reset: '重置密码',
}

const handleSuccess = () => {
  dialogVisible.value = false
}

const handleClose = () => {
  activeTab.value = 'login'
}

const handleSwitchTab = (tab: string) => {
  activeTab.value = tab
}
</script>

<template>
  <!-- el-dialog 弹窗组件 
    弹窗组件 用于触发点击事件 在页面 弹出一个弹窗
    v-model 绑定一个布尔值变量 这个变量为true时将触发弹窗
    v-model="dialogVisible" 控制弹窗显示

    :title="tabTitles[activeTab]" 设置弹窗标题
    v-bind:title vue 绑定属性写法 动态绑定组件一个属性值
    img为标签 src是基本属性

    三元表达式 条件:true ? 表达式1 : 表达式2
    :width="isMobile() ? '100%' : '500px'" 设置弹窗宽度

    @success 绑定事件
  -->
  <el-dialog
    v-model="dialogVisible"
    :title="tabTitles[activeTab]"
    :width="isMobile() ? '100%' : '500px'"
    destroy-on-close
    @close="handleClose"
  >
    <div>
      <!-- el-tabs 页签组件 封装思想 有一个导航栏的作用 -->
      <el-tabs v-model="activeTab" class="auth-tabs">
        <!-- 登录页签 -->
        <el-tab-pane name="login" :label="tabTitles.login">
          <LoginForm 
            @success="handleSuccess" 
            @switch-tab="handleSwitchTab" 
          />
        </el-tab-pane>
        <!-- 注册页签 -->
        <el-tab-pane name="register" :label="tabTitles.register">
          <RegisterForm
            @success="handleSuccess"
            @switch-tab="handleSwitchTab"
          />
        </el-tab-pane>
        <!-- 重置密码页签 -->
        <el-tab-pane name="reset" :label="tabTitles.reset">
          <ResetPasswordForm
            @success="handleSuccess"
            @switch-tab="handleSwitchTab"
          />
        </el-tab-pane>

      </el-tabs>
    </div>
  </el-dialog>
</template>

<style scoped>
.auth-tabs ::v-deep(.el-tabs__nav) {
  width: 100%;
  display: flex;
  justify-content: center; /* 确保导航居中 */
}

.auth-tabs ::v-deep(.el-tabs__item) {
  flex: 1;
  text-align: center;
}
</style>
