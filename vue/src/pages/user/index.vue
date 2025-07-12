<script lang="ts" setup>
import defaultCoverImg from '@/assets/song.jpg'
import { computed, onMounted, reactive, ref } from 'vue'
// 导入必要的接口类型和接口函数
import { RecommendedPlay } from '@/api/interface'
import { getFavoritePlaylists, getFavoriteSongs, getUserInfo, resetPassword, sendEmailCode, updateUserAvatar, updateUserInfo } from '@/api/system'
import defaultAvatar from '@/assets/user.jpg'
import router from '@/routers'
import { Upload, VideoPlay } from '@element-plus/icons-vue'
import { ElMessage, FormInstance, FormRules } from 'element-plus'

// ================= 登录状态 =================
//导入用户缓存
const userStore = UserStore()
// 检查用户是否登录
const checkLogin = () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning("请先登录")
    showLoginDialog()
    return false
  }
  return true
}
//调用登录组件
// 导入路由对象
const showLoginDialog = () => {
  //事件总线 调用 登录事件
  emitter.emit('show-login-dialog', { show: true })
}
// 在原有的watch监听登录状态变化部分添加刷新逻辑
watch(() => userStore.isLoggedIn, (newVal) => {
  if (newVal) {
    // 用户登录成功，显示成功消息
    ElMessage.success('登录成功！正在加载您的个人信息...');
    // 重新加载用户信息
    fetchUserInfo();
    // 刷新页面数据
    getMySongs();
    if (activeTab.value === 'collected') {
      fetchCollectedPlaylists();
    }
    // 如果需要完全刷新页面，可以取消下面的注释
    setTimeout(() => {
      location.reload();
    }, 500);
  }
})

// ============== 状态信息 ==============
const isEditing = ref(false)
const activeTab = ref('collected') // 初始激活歌单页签
// 当前等级经验值
const currentExp = ref(22825)
// 升级所需总经验值
const requiredExp = ref(28800)
// 计算进度百分比
const levelPercentage = computed(() => {
  return Math.min(100, (currentExp.value / requiredExp.value) * 100)
})

// ================== 喜欢歌曲数 ==================
// 1. 存储歌曲总数的分页配置
const pageConfigsongs = reactive({
  total: 0,
  pageNum: 1,
  pageSize: 10,
})
// 2. 定义获取歌曲数据的方法
const getMySongs = async () => {
  try {
    const result = await getFavoriteSongs({
      pageNum: pageConfigsongs.pageNum,
      pageSize: pageConfigsongs.pageSize,
      songName: '',
    })
    if (result.code === 0 && result.data) {
      pageConfigsongs.total = result.data.total
    }
  } catch (error) {
    console.error('获取歌曲总数失败：', error)
  }
}

// ============================== 收藏歌单 =============================
// 推荐歌单
const playlist = ref<RecommendedPlay[]>([])
// 当前页
const currentPage = ref(1)
// 每页显示多少条
const pageSize = ref(10)
// 总数
const total = ref(0)
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: total.value,
  pageSizes: [10, 15, 20],
})
// 查询参数
const queryParams = ref({
  pageNum: currentPage.value,
  pageSize: pageSize.value,
  title: null,
  style: null,
})
// 切换页签事件
const fetchCollectedPlaylists = async () => {
  const result = await getFavoritePlaylists(queryParams.value);
  if (result.code === 0) {
    playlist.value = result.data.items as RecommendedPlay[];
    pageConfig.total = result.data.total;
  } else {
    ElMessage.error('获取歌单失败');
  }
};

const handleSwitchTab = async (name: any) => {
  // 当前页签名称
  const currentTab = name.props.label
  if (currentTab === '我收藏的歌单') {
    await fetchCollectedPlaylists()
  }
}

// ============================== 个人信息 ==============================
interface UserInfo {
  id?: number;
  username?: string;
  email?: string;
  introduction?: string;
  userAvatar?: string | null;
  phone?: string;
}

const userInfo = ref<UserInfo>({
  username: '酷狗用户',
  email: 'user@example.com',
  introduction: '这个人很懒，什么都没留下',
  userAvatar: defaultAvatar || '',
  phone: '1234567890',
})
// 获取用户信息
const fetchUserInfo = async () => {
  if (!checkLogin()) return
  const res = await getUserInfo();
  if (res.code === 0) {
    console.log('✅ 获取到的用户信息如下：');
    userInfo.value = res.data as UserInfo
    console.log(userInfo.value);

  } else {
    console.warn('⚠️ 获取用户信息失败:', res.message);
  }
};

// 切换编辑状态
const toggleEditing = () => {
  isEditing.value = !isEditing.value;
};

// 保存用户信息
const saveUserInfo = async () => {

  // 调用API更新用户信息
  const result = await updateUserInfo(userInfo.value)
  if (result.code === 0) {

    userStore.updateUsername(userInfo.value.username)
    // fetchUserInfo()
    ElMessage.success('个人信息更新成功');
    // userStore.setUserInfo(userInfo.value)
    toggleEditing(); // 关闭编辑状态

  } else {
    ElMessage.error('更新失败: ' + result.message);
  }
};

// 当前激活的标签页
const activeTabself = ref('info');
const tabs = [
  { id: 'info', label: '个人信息' },
  { id: 'password', label: '修改密码' },
  { id: 'avatar', label: '头像设置' },
  { id: 'delete', label: '注销账号' },
];

// ======================== 修改密码 ========================
const countdown = ref(0)
const resetFormRef = ref<FormInstance>()
let timer: NodeJS.Timeout | null = null

const resetForm = reactive({
  oldPassword: '',
  email: '',
  verificationCode: '',
  newPassword: '',
  repeatPassword: ''
})

// 表单验证规则
const resetRules = reactive<FormRules>({
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' },
  ],
  verificationCode: [ // 对应修改规则名称
    { required: true, message: '请输入验证码', trigger: 'blur' },
    {
      pattern: /^[0-9a-zA-Z]{6}$/,
      message: '验证码格式：6位字符（大小写字母、数字）',
      trigger: 'blur',
    },
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    {
      pattern: /^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z\W]{8,18}$/,
      message: '密码格式：8-18位数字、字母、符号的任意两种组合',
      trigger: 'blur',
    },
  ],
  repeatPassword: [ // 对应修改规则名称
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule: any, value: string, callback: Function) => {
        if (value !== resetForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur',
    },
  ],
})

// 发送验证码
const sendVerificationCode = async () => {
  try {
    if (!resetForm.email) {
      ElMessage.warning('请先输入邮箱')
      return
    }
    const response = await sendEmailCode(resetForm.email)
    if (response.code === 0) {
      ElMessage.success('验证码已发送')
      countdown.value = 60
      timer = setInterval(() => {
        countdown.value--
        if (countdown.value <= 0) {
          if (timer) {
            clearInterval(timer)
            timer = null
          }
        }
      }, 1000)
    } else {
      ElMessage.error(response.message)
    }
  } catch (error: any) {
    ElMessage.error(error.message || '发送验证码失败')
  }
}
const loading = ref(false)
// 重置密码处理
const handleResetPassword = async () => {
  if (!resetFormRef.value) return
  await resetFormRef.value.validate(async (valid, fields) => {
    console.log("表单", resetFormRef.value)

    if (valid) {
      loading.value = true
      try {
        const response = await resetPassword(resetForm)
        if (response.code === 0) {
          ElMessage.success('密码重置成功')
        } else {
          ElMessage.error(response.message)
        }
      } catch (error: any) {
        ElMessage.error(error.message || '密码重置失败')
      } finally {
        loading.value = false
      }
    } else {
      console.log('验证失败:', fields)
    }
  })
}

// 组件卸载时清除定时器
onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
    timer = null
  }
})


// ======================= 更新头像 =======================
// 头像预览
const previewImage = ref(null);

// 头像上传相关状态
const uploadProgress = ref(0)

// 图片上传之前验证
const beforeAvatarUpload = (rawFile: File) => {
  const isJPG = rawFile.type === 'image/jpeg' || rawFile.type === 'image/png';
  if (!isJPG) {
    ElMessage.error('头像图片只能是JPG/PNG格式!');
    return false;
  }
  return true;
}

// 头像上传处理

const handleAvatarUpload = async (event: any) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning("请先登录")
    return
  }
  const fileInput = event.target as HTMLInputElement;
  const file = fileInput.files?.[0];
  const reader = new FileReader();
  if (!file || !beforeAvatarUpload(file)) {
    return;
  }
  reader.onload = (e) => {
    previewImage.value = e.target?.result
  }
  reader.readAsDataURL(file)
  //声明一个表单
  const form = new FormData()
  //表单添加图片
  form.append('avatar', file)
  //获取后台接口地址 之前发送
  // json格式数据 或者
  // 文本类型数据 
  // 二进制数据类型
  const result = await updateUserAvatar(form)
  //头像上传成功
  if (result.code === 0) {
    userInfo.value.userAvatar = result.data
    userStore.updateUserAvatar(userInfo.value.userAvatar)
    ElMessage.success("头像更换成功")
  }
}


// 监听登录状态变化，更新头像
watch(() => userStore.isLoggedIn, (newVal) => {
  if (newVal) {
    // 用户登录成功，更新头像预览
    previewImage.value = null;
  }
})
onMounted(async () => {
  getMySongs(); // 初始化获取数据，更新pageConfig.total
  if (activeTab.value === 'collected') {
    await fetchCollectedPlaylists(); // 页面加载时直接获取
  }
  await fetchUserInfo();

})
</script>


<template>
  <div class="music-page">
    <!-- 个人信息栏 -->
    <div class="profile-section flex flex-col md:flex-row items-center p-6 bg-card rounded-xl shadow-sm mb-6">
      <div class="relative avatar-container mb-4 md:mb-0 mx-auto md:mx-0">
        <img :src="userStore.userInfo.avatarUrl || defaultAvatar"
          class="avatar w-24 h-24 rounded-full object-cover border-4 border-primary/20" alt="头像" />
        <input type="file" accept="image/*" @change="handleAvatarUpload" ref="avatarFileInput" hidden />
      </div>

      <div class="profile-info ml-0 md:ml-6 text-center md:text-left w-full">
        <h1 class="username text-2xl font-bold">{{ userInfo.username || '加载中...' }}</h1>
        <div class="level flex items-center justify-center md:justify-start mt-1">
          LV5 {{ currentExp }}/{{ requiredExp }}
          <el-tag type="gray" class="ml-2">非会员</el-tag>
        </div>
        <!-- 进度条 -->
        <el-progress :percentage="levelPercentage" :stroke-width="4" color="#FF7D00" :show-text="false"
          class="level-progress w-full md:w-48 mt-2 mx-auto md:mx-0">
        </el-progress>
        <div class="stats mt-3 flex flex-col md:flex-col gap-1 justify-center md:justify-start">
          <span class="text-muted-foreground">共有 {{ pageConfigsongs.total }} 首喜欢的歌曲</span>
          <span class="text-muted-foreground">共有 {{ pageConfig.total }} 个喜欢的歌单</span>
        </div>
      </div>
    </div>

    <!-- 页签导航 -->
    <el-tabs v-model="activeTab" @tab-click="handleSwitchTab" class="overflow-auto w-full">
      <!-- 歌单列表 -->
      <el-tab-pane label="我收藏的歌单" name="collected">
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-3">
          <div class="rounded-2xl transition duration-300 bg-card cursor-pointer hover:shadow-lg hover:bg-background"
            v-for="item in playlist" :key="item.playlistId" @click="router.push('/playlist/' + item.playlistId)">
            <div class="p-0">
              <div class="relative">
                <!-- 歌单封面 -->
                <el-image :src="item.coverUrl" width="200" height="200" loading="lazy"
                  class="w-full h-48 md:h-64   object-cover rounded-t-2xl overflow-hidden">
                  <template #placeholder>
                    <el-image :src="defaultCoverImg" />
                  </template>
                </el-image>

                <!-- 播放图标 -->
                <el-icon color="white" size="40" class="absolute right-2 bottom-4 z-10">
                  <VideoPlay />
                </el-icon>
              </div>

              <!-- 歌单名字 -->
              <div class="flex h-16   p-2">
                <h3 class="line-clamp-2  font-medium playlist-title">{{ item.title }}</h3>
              </div>

              <!-- 歌单创建人信息行 垂直居中 左对齐-->
              <div class="flex flex-row p-2 items-center justify-start">
                <el-image class=" w-8 h-8" :src="item.createAvatar || defaultCoverImg"></el-image>
                <h3 class="line-clamp-2 ml-2  font-medium playlist-title">{{ item.createUsername }}</h3>
              </div>
            </div>
          </div>
        </div>
      </el-tab-pane>

      <!-- 个人信息页签 -->
      <el-tab-pane label="我的信息" name="profile">
        <div class="personal-center flex flex-col md:flex-row gap-6 mt-4">
          <!-- 侧边栏 -->
          <aside class="sidebar w-full md:w-64 bg-card p-5 rounded-xl shadow-sm">
            <!-- 个人信息栏 -->
            <div v-if="false" class="user-info text-center mb-6">
              <div class="relative inline-block">
                <img :src="userInfo.userAvatar || defaultAvatar"
                  class="avatar w-20 h-20 rounded-full mx-auto object-cover" />
              </div>
              <h2 class="mt-3 font-semibold">{{ userInfo?.username || '用户名' }}</h2>
              <p class="text-sm text-gray-500">{{ userInfo?.email || '未设置邮箱' }}</p>
              <p class="text-sm text-gray-800">{{ userInfo?.introduction || '未设置个性签名' }}</p>
            </div>
            <input type="file" accept="image/*" @change="handleAvatarUpload" ref="sidebarAvatarInput" hidden />
            <nav>
              <button v-for="tab in tabs" :key="tab.id" :class="['tab-button w-full py-3 px-4 text-left rounded-lg transition-all mb-1',
                {
                  'bg-primary/10 text-primary font-medium': activeTabself === tab.id,
                  'hover:bg-gray-100': activeTabself !== tab.id
                }]" @click="activeTabself = tab.id">
                {{ tab.label }}
              </button>
            </nav>
          </aside>

          <!-- 右侧内容区 -->
          <main class="main-content flex-1">
            <!-- 个人信息 -->
            <div v-if="activeTabself === 'info'" class="card bg-card p-6 rounded-xl shadow-sm">
              <div class="flex justify-between items-center mb-6">
                <h2 class="text-xl font-semibold">个人信息</h2>
                <el-button @click="toggleEditing" type="primary" size="small">
                  {{ isEditing ? '取消编辑' : '编辑信息' }}
                </el-button>
              </div>

              <form @submit.prevent="saveUserInfo" class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div class="form-group">
                    <label class="block text-sm font-medium mb-2 text-gray-700">用户名</label>
                    <el-input v-model="userInfo.username" :disabled="!isEditing" placeholder="请输入用户名" />
                  </div>

                  <div class="form-group">
                    <label class="block text-sm font-medium mb-2 text-gray-700">邮箱</label>
                    <el-input v-model="userInfo.email" :disabled="!isEditing" placeholder="请输入邮箱" type="email" />
                  </div>

                  <div class="form-group">
                    <label class="block text-sm font-medium mb-2 text-gray-700">手机号</label>
                    <el-input v-model="userInfo.phone" :disabled="!isEditing" placeholder="请输入手机号" />
                  </div>

                  <div class="form-group">
                    <label class="block text-sm font-medium mb-2 text-gray-700">个性签名</label>
                    <el-input v-model="userInfo.introduction" :disabled="!isEditing" placeholder="请输入个性签名" />
                  </div>
                </div>

                <div v-if="isEditing" class="flex justify-end pt-4 border-t border-gray-100">
                  <el-button type="primary" @click="saveUserInfo">保存修改</el-button>
                </div>
              </form>
            </div>

            <!-- 修改密码 -->
            <div v-if="activeTabself === 'password'" class="card bg-card p-6 rounded-xl shadow-sm">
              <h2 class="text-xl font-semibold mb-6">修改密码</h2>
              <el-form ref="resetFormRef" :model="resetForm" :rules="resetRules" @submit.prevent="handleResetPassword"
                class="space-y-5">
                <div class="form-group">
                  <label class="block text-sm font-medium mb-2 text-gray-700">当前密码</label>
                  <el-input v-model="resetForm.oldPassword" type="password" placeholder="请输入当前密码" required />
                </div>

                <div class="form-group">
                  <label class="block text-sm font-medium mb-2 text-gray-700">新密码</label>
                  <el-input v-model="resetForm.newPassword" type="password" placeholder="请输入新密码" required />
                  <p class="text-xs text-gray-500 mt-1">密码长度至少6位，包含字母和数字</p>
                </div>

                <div class="form-group">
                  <label class="block text-sm font-medium mb-2 text-gray-700">确认密码</label>
                  <el-input v-model="resetForm.repeatPassword" type="password" placeholder="请再次输入新密码" required />
                  <el-alert
                    v-if="resetForm.newPassword && resetForm.repeatPassword && resetForm.newPassword !== resetForm.repeatPassword"
                    title="两次输入的密码不一致" type="error" :closable="false" class="mt-2 text-xs">
                  </el-alert>
                </div>

                <div class="form-group flex flex-col">
                  <label class="block text-sm font-medium mb-2 text-gray-700">邮箱验证</label>
                  <div class="flex flex-row ">
                    <div class="flex gap-2 mr-2 w-1/2">
                      <el-input v-model="resetForm.email" placeholder="请输入您的邮箱" required />
                    </div>
                    <div class="flex gap-2 w-1/2">
                      <el-input v-model="resetForm.verificationCode" placeholder="请输入验证码" required />
                      <el-button :disabled="!!countdown || loading" @click="sendVerificationCode">
                        {{ countdown ? `${countdown}s后重试` : '获取验证码' }}
                      </el-button>
                    </div>
                  </div>

                </div>

                <div class="flex justify-end pt-4 border-t border-gray-100">
                  <el-button type="primary" @click="handleResetPassword"
                    :disabled="resetForm.newPassword !== resetForm.repeatPassword || !resetForm.newPassword">
                    重置密码
                  </el-button>
                </div>
              </el-form>
            </div>

            <!-- 头像上传 -->
            <div v-if="activeTabself === 'avatar'" class="card bg-card p-6 rounded-xl shadow-sm">
              <h2 class="text-xl font-semibold mb-6">头像设置</h2>

              <div class="flex flex-col items-center">
                <div class="avatar-upload-container relative w-40 h-40 mb-6 cursor-pointer"
                  @click="$refs.avatarFileInput.click()">
                  <img :src="previewImage || userStore.userInfo.avatarUrl || defaultAvatar" alt="用户头像"
                    class="w-full h-full object-cover rounded-full border-4 border-gray-200" />
                  <div
                    class="absolute inset-0 bg-black/30 rounded-full flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity">
                    <el-icon color="white" size="24">
                      <Upload />
                    </el-icon>
                  </div>
                </div>

                <input type="file" accept="image/*" @change="handleAvatarUpload" ref="avatarFileInput" hidden />

                <div class="text-center w-full max-w-md">
                  <p class="text-sm text-gray-500 mb-4">点击上方头像区域上传新头像</p>
                  <p class="text-xs text-gray-400">支持JPG、PNG格式，建议尺寸不小于200x200像素</p>

                  <el-progress v-if="uploadProgress > 0 && uploadProgress < 100" :percentage="uploadProgress"
                    class="mt-4 w-full"></el-progress>
                </div>
              </div>
            </div>

            <!-- 注销账号 -->
            <div v-if="activeTabself === 'delete'" class=" bg-white rounded-xl card-shadow p-6 mb-6">
              <h2 class="text-xl font-semibold mb-6 flex items-center text-danger">
                <i class="fa fa-trash-o mr-3 "></i>注销账号
              </h2>

              <div class="bg-danger/10 p-4 rounded-lg mb-6">
                <h3 class="font-medium text-red-500 mb-2">重要提示</h3>
                <ul class="list-disc pl-5 space-y-1 text-gray-1">
                  <li class="text-red-500">注销账号将删除您的所有个人信息和历史记录，无法恢复。</li>
                  <li class="text-red-500">注销后，您将无法再使用此账号登录。</li>
                </ul>
              </div>

              <form id="delete-form" class="space-y-4">
                <div>
                  <label class="block text-gray-1 text-sm mb-1">请输入密码确认</label>
                  <input type="password" id="delete-password"
                    class="w-full px-4 py-2 border border-gray-3 rounded-lg focus:outline-none focus:ring-2 focus:ring-danger/50 focus:border-danger transition-custom"
                    placeholder="请输入您的密码">
                </div>
                <div class="flex items-start">
                  <input type="checkbox" id="delete-agree"
                    class="mt-1 mr-2 h-4 w-4 text-danger focus:ring-danger border-gray-3 rounded">
                  <label for="delete-agree" class="text-gray-1 text-sm">我已阅读并同意注销账号的相关条款</label>
                </div>
                <div class="flex justify-end space-x-3 pt-4 border-t border-gray-4">
                  <button type="button" id="cancel-delete-btn"
                    class="px-6 py-2 border border-gray-3 rounded-lg text-gray-1 hover:bg-gray-4 transition-custom">取消</button>
                  <button type="submit" id="confirm-delete-btn"
                    class="px-6 py-2 bg-danger text-white rounded-lg hover:bg-danger/90 transition-custom flex items-center opacity-50 cursor-not-allowed"
                    disabled>
                    <i class="fa fa-trash-o mr-2"></i>确认注销
                  </button>
                </div>
              </form>
            </div>
          </main>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>



<style scoped>
.music-page {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.profile-section {
  display: flex;
  align-items: center;
  margin-bottom: 32px;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  margin-right: 24px;
}

.profile-info {
  flex: 1;
}

.username {
  font-size: 24px;
  margin-bottom: 8px;
}

.level {
  color: #666;
  margin-bottom: 12px;
}

.stats span {
  margin-right: 24px;
  color: #999;
}

.tab-nav {
  border: none;
  /* 去除Element Plus默认边框 */
}

.tab-content {
  padding: 24px;
  background: #f8f9fa;
  min-height: 300px;
}

.sidebar {
  text-align: center;
}

.sidebar .user-info {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.sidebar .avatar {
  margin-right: 0;
}

.sidebar .tab-button {
  text-align: left;
}
</style>