<script setup lang="ts">
import { reactive, ref } from 'vue'
import { Lock, Message } from '@element-plus/icons-vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { UserStore } from '@/stores/modules/user'

const emit = defineEmits(['success', 'switch-tab'])
const userStore = UserStore()

const loading = ref(false)
const loginFormRef = ref<FormInstance>()

const loginForm = reactive({
  email: '',
  password: '',
})

// 表单验证规则
const loginRules = reactive<FormRules>({
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    {
      pattern: /^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z\W]{8,18}$/,
      message: '密码格式：8-18位数字、字母、符号的任意两种组合',
      trigger: 'blur',
    },
  ],
})

function switchToRegister() {
  // 通知父组件切换到注册标签
  emit('switch-tab', 'register')
}

function switchToReset() {
  // 通知父组件切换到重置密码标签
  emit('switch-tab', 'reset')
}
// 一般来说，方法使用箭头函数形式
// async 表示该方法是一个异步方法
const handleLogin = async () => {
  // 处理登录按钮的点击事件逻辑
  // 0. 校验用户输入
  if(!loginFormRef.value){
    return
  }
  // 0.1 验证表单规则是否正确
  // validate 主动调用表单内的规则去验证
  // callback 回调函数 用于告知验证是否成功 传递一个boolean
  await loginFormRef.value.validate(async(valid) => {
    // 通过校验
    if(valid){
      // 1. 获取邮箱和密码 封装进了loginForm对象
      // 2. 调用登录接口，发生网络请求到后台登录 
      /**
        使用网络请求 ajax fetch Axios 现代化的网络请求工具
        get post put delete
        Promise 异步编程对象 
        await 等待userLogin 函数执行完毕之后，再处理下一步
      */

      const result = await userStore.userLogin(loginForm)
      /**
       result = {
        success: boolean,
        message: string
       }
      */
      // 判断 登录是否成功 成功之后执行
      if (result.success) {
        // 使用ElementUI中消息组件
        ElMessage.success(result.message)
        // 事件透传，告知父组件登录操作已经完毕
        emit('success')
      }else {
        ElMessage.error(result.message)
      }
    }
  })

}

</script>

<template>
  <div class="login-container">
    <p class="form-subtitle">输入您的邮箱以登录您的账户</p>

    <el-form
      ref="loginFormRef"
      :model="loginForm"
      :rules="loginRules"
      label-width="0"
      size="large"
      @keyup.enter="null"
    >
      <el-form-item prop="email">
        <el-input
          v-model="loginForm.email"
          placeholder="邮箱"
          :prefix-icon="Message"
        />
      </el-form-item>

      <el-form-item prop="password" class="mt-6">
        <el-input
          v-model="loginForm.password"
          type="password"
          placeholder="密码"
          :prefix-icon="Lock"
          show-password
        />
      </el-form-item>

      <div class="forgot-password">
        <a href="#" @click.prevent="switchToReset">忘记密码？</a>
      </div>

      <el-form-item class="mt-6">
        <el-button
          class="submit-btn"
          type="primary"
          :loading="loading"
          @click="handleLogin"
        >
          登录
        </el-button>
      </el-form-item>
    </el-form>

    <p class="signup-text">
      没有账户？
      <a href="#" @click.prevent="switchToRegister">注册</a>
    </p>
  </div>
</template>

<style scoped>
.login-container {
  width: 100%;
  max-width: 400px;
  margin: 0 auto;
  padding: 20px;
}

.form-subtitle {
  color: #666;
  margin-bottom: 24px;
  font-size: 14px;
}

:deep(.el-form-item) {
  margin-bottom: 20px;
}

:deep(.el-input__wrapper) {
  border-radius: 8px;
}

.submit-btn {
  width: 100%;
  border-radius: 8px;
  height: 40px;
  font-size: 16px;
}

.signup-text {
  text-align: center;
  margin-top: 16px;
  color: #666;
}

.signup-text a {
  color: #2a68fa;
  font-weight: 600;
  text-decoration: none;
}

.signup-text a:hover {
  text-decoration: underline;
}

.forgot-password {
  text-align: right;
  margin: -10px 0 10px;
}

.forgot-password a {
  color: #666;
  font-size: 14px;
  text-decoration: none;
}

.forgot-password a:hover {
  color: #2a68fa;
  text-decoration: underline;
}
</style>
