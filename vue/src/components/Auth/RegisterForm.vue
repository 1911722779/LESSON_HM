<script setup lang="ts">
import { reactive, ref } from 'vue'
import { Key, Lock, Message, User } from '@element-plus/icons-vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { register, sendEmailCode } from '@/api/system'

const emit = defineEmits(['success', 'switch-tab'])

const loading = ref(false)
const countdown = ref(0)
const registerFormRef = ref<FormInstance>()

const registerForm = reactive({
  username: '',
  email: '',
  password: '',
  verificationCode: '',
})

// 表单验证规则
const registerRules = reactive<FormRules>({
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    {
      pattern: /^[a-zA-Z0-9_-]{4,16}$/,
      message: '用户名格式：4-16位字符（字母、数字、下划线、连字符）',
      trigger: 'blur',
    },
  ],
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
  verificationCode: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    {
      pattern: /^[0-9a-zA-Z]{6}$/,
      message: '验证码格式：6位字符（大小写字母、数字）',
      trigger: 'blur',
    },
  ],
})

function switchToLogin() {
  // 通知父组件切换到登录标签
  emit('switch-tab', 'login')
}

// 注册处理函数
const handleRegistry = async () => {
  /**
   * 1. 校验表单规则
   * 2. 发送邮件验证码
   * 3. 发送注册请求
   */

  // 检验表单规则
  if (!registerFormRef.value) {
    return
  } 

  // validate (callback( valid,fields ) )
  registerFormRef.value.validate(async (valid) => {
    if (valid) {
      // 发送注册请求
      const result = await register(registerForm)
      /**
       * http 中 200代表成功 302代表转发 401代表未鉴权 500代表服务器内部异常
       * {
       *   code: number; // 返回码  0代表成功 1代表失败
       *   message: string; // 返回信息 
       *   data?: Array<any> | number | string | object;
       * }
       * == 不判断类型 '1' = 1
       * === 判断类型和值 '1' != 1
       */
      if (result.code === 0) {
        ElMessage.success('注册成功')
        // 通知父组件 切换到登录页面
      } else {
        ElMessage.error(result.message)
      }

    }
  })
}
// 发送验证码功能
const handleSendCode = async () => {
    // 1. 校验邮箱
    if(!registerForm.email) {
      ElMessage.warning('请输入邮箱')
      return
    }
    // 2. 发送邮箱请求
    const result = await sendEmailCode(registerForm.email)
    // 2.1 发送成功
    if (result.code ===0) {
      // 3. 倒计时1分钟后才能继续发送
      ElMessage.success('验证码发送成功')

      // 使用定时器 setInterval 每秒更新值 从60开始倒计时 到0结束
      countdown.value = 60
      const timer = setInterval(() =>{
        // 从60开始自减
        countdown.value--
        // 当数值为0时 清除定时器 可以再次发送验证码
        if (countdown.value <= 0) { 
          // 结束当前定时器
          clearInterval(timer)
        }
      }, 1000)
    } else {
      ElMessage.error(result.message)
    }
    
  }
</script>

<template>
  <div class="register-container">
    <p class="form-subtitle">创建一个新账户</p>

    <el-form
      ref="registerFormRef"
      :model="registerForm"
      :rules="registerRules"
      label-width="0"
      size="large"
      @keyup.enter="null"
    >
      <el-form-item prop="username">
        <el-input
          v-model="registerForm.username"
          placeholder="用户名"
          :prefix-icon="User"
        />
      </el-form-item>

      <el-form-item prop="email" class="mt-6">
        <el-input
          v-model="registerForm.email"
          placeholder="邮箱"
          :prefix-icon="Message"
        >
          <template #append>
            <el-button :disabled="!!countdown || loading" @click="handleSendCode">
              {{ countdown ? `${countdown}s后重试` : '获取验证码' }}
            </el-button>
          </template>
        </el-input>
      </el-form-item>

      <el-form-item prop="verificationCode" class="mt-6">
        <el-input
          v-model="registerForm.verificationCode"
          placeholder="验证码"
          :prefix-icon="Key"
        />
      </el-form-item>

      <el-form-item prop="password" class="mt-6">
        <el-input
          v-model="registerForm.password"
          type="password"
          placeholder="密码"
          :prefix-icon="Lock"
          show-password
        />
      </el-form-item>

      <el-form-item class="mt-6">
        <el-button
          class="submit-btn"
          type="primary"
          :loading="loading"
          @click="handleRegistry"
        >
          注册
        </el-button>
      </el-form-item>
    </el-form>

    <p class="login-text">
      已有账户？
      <a href="#" @click.prevent="switchToLogin">登录</a>
    </p>
  </div>
</template>

<style scoped>
.register-container {
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

.login-text {
  text-align: center;
  margin-top: 16px;
  color: #666;
}

.login-text a {
  color: #2a68fa;
  font-weight: 600;
  text-decoration: none;
}

.login-text a:hover {
  text-decoration: underline;
}
</style>
