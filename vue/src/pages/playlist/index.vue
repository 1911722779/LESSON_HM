<script setup lang="ts">
import { RecommendedPlay } from '@/api/interface'
import {
  getAllPlaylists,
  getFavoritePlaylists,
  newPlaylist,
} from '@/api/system'
import defaultCoverImg from '@/assets/cover.png'
import router from '@/routers'
import { isMobile } from '@/utils'
import { Search, VideoPlay } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const styleTags = ref([
  { name: '全部' },
  { name: '节奏布鲁斯' },
  { name: '欧美流行' },
  { name: '华语流行' },
  { name: '粤语流行' },
  { name: '国风流行' },
  { name: '韩语流行' },
  { name: '日本流行' },
  { name: '嘻哈说唱' },
  { name: '非洲节拍' },
  { name: '原声带' },
  { name: '轻音乐' },
  { name: '摇滚' },
  { name: '朋克' },
  { name: '电子' },
  { name: '国风' },
  { name: '乡村' },
  { name: '古典' },
])
// 当前页
const currentPage = ref(1)
//每页显示多少条
const pageSize = ref(10)
// 总数
const total = ref(0)

//搜索变量
const searchKeyWord = ref('')

//类别搜索变量
const styleTag = ref('')

//控制新建歌单对话框变量
const showNewDialog = ref(false)

//定义新建歌单标题变量
const playlistName = ref('')

//定义一个统一配置 让 分页组件绑定这个配置 reactive针对复杂对象响应式
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
  title: null, //歌单标题
  style: null, //歌单风格
})

//页码 与 当前页 变更事件
/**
 * (currentPage: number, pageSize: number)
 */
const handleChange = async (currentPage: number, pageSize: number) => {
  // 更新页码与当前页数据
  queryParams.value.pageNum = currentPage
  queryParams.value.pageSize = pageSize
  await getPlayList(queryParams.value)
}

// 歌单页签数组
const playListType = ref(['精选歌单', '我的收藏'])
// 推荐歌单
const playlist = ref([])

// 条件查询歌单方法
const getPlayList = async (queryParams: any) => {
  //发送网络请求 获取推荐歌单
  const result = await getAllPlaylists(queryParams)
  //判断一下成功与否 还需要判断一下是否是数组类型
  if (result.code === 0) {
    playlist.value = result.data.items as RecommendedPlay[]
    pageConfig.total = result.data.total
  } else {
    ElMessage.error('获取歌单失败')
  }
}

// 搜索事件

const handleSearch = async () => {
  // 查询参数填充值
  queryParams.value.title = searchKeyWord.value
  //重置一下当前页码
  queryParams.value.pageNum = 1
  //查询歌单
  await getPlayList(queryParams.value)
}

//类别选择事件
const handleSelectTag = async () => {
  // 查询参数填充值
  queryParams.value.style = styleTag.value === '全部' ? null : styleTag.value
  //重置一下当前页码
  queryParams.value.pageNum = 1
  //查询歌单
  await getPlayList(queryParams.value)
}

// 切换页签事件 name 页签名
const handleSwitchTab = async (name: any) => {
  //当前页签名称
  const currentTab = name.props.label
  if (currentTab === '我的收藏') {
    //获取用户收藏的歌单列表
    const result = await getFavoritePlaylists(queryParams.value)

    //判断一下成功与否 还需要判断一下是否是数组类型
    if (result.code === 0) {
      playlist.value = result.data.items as RecommendedPlay[]
      pageConfig.total = result.data.total
    } else {
      ElMessage.error('获取歌单失败')
    }
  } else {
    //默认查询精选歌单
    await getPlayList(queryParams.value)
  }
}

//新建歌单方法
const handleNewPlaylist = async () => {
  //1. 发送创建歌单请求
  const result = await newPlaylist(playlistName.value)
  if (result.code === 0) {
    const newPlaylistId = result.data
    //2. 关闭对话框
    showNewDialog.value = false
    //3. 跳转到对应的新歌单详情页
    router.push('/playlist/' + newPlaylistId)
  } else {
    ElMessage.error(result.message)
  }
}

onMounted(async () => {
  await getPlayList(queryParams.value)
})
</script>


<template>
  <div class="flex flex-col gap-y-4 h-full px-4 mx-4 mt-4">
    <!-- 功能栏 flex 左对齐 -->
    <div class="flex flex-row justify-start items-center gap-x-2">
      <!-- 搜索框 -->
      <!-- 复合型输入框  左边 有一个icon  右边是输入框 -->
      <el-input
        class="w-64"
        @keyup.enter="handleSearch"
        v-model="searchKeyWord"
        size="large"
        placeholder="请输入歌单名称"
        :prefix-icon="Search"
      />
      <!-- 列表下拉框 -->
      <el-select class="w-64" v-model="styleTag" @change="handleSelectTag">
        <el-option
          v-for="item in styleTags"
          :key="item.name"
          :label="item.name"
          :value="item.name"
        />
      </el-select>

      <!-- 添加歌单按钮 -->
      <el-button type="primary" size="large" @click="showNewDialog = true"
        >新建歌单</el-button
      >
    </div>

    <!-- 页签 或者 导航栏  flex-1 让元素占整个父容器 全部剩余空间 -->
    <div class="flex flex-1">
      <el-tabs
        type="border-card"
        class="overflow-auto w-full"
        @tab-click="handleSwitchTab"
      >
        <!-- 精选歌单 -->
        <el-tab-pane v-for="item in playListType" :key="item" :label="item">
          <div class="grid grid-cols-3 md:grid-cols-5 gap-4 mt-3">
            <div
              class="rounded-2xl transition duration-300 bg-card cursor-pointer hover:shadow-lg hover:bg-background"
              v-for="item in playlist"
              :key="item.playlistId"
              @click="router.push('/playlist/' + item.playlistId)"
            >
              <!-- 卡片容器 相对布局 -->
              <div class="p-0">
                <!-- 这个div 宽高自适应的图片宽高  实现层叠布局-->
                <div class="relative">
                  <!-- 歌单封面 -->
                  <el-image
                    :src="item.coverUrl"
                    width="200"
                    height="200"
                    loading="lazy"
                    class="w-full h-full object-cover rounded-t-2xl overflow-hidden"
                  >
                    <!-- 占位内容,加载比较慢的情况下 默认先贴一张静态图显示一下 -->
                    <template #placeholder>
                      <el-image :src="defaultCoverImg" />
                    </template>
                  </el-image>

                  <!-- 播放图标 负边距  -->
                  <el-icon
                    color="white"
                    size="40"
                    class="absolute right-2 bottom-4 z-10"
                  >
                    <VideoPlay />
                  </el-icon>
                </div>

                <!-- 歌单名字 -->
                <div class="flex h-16 p-2">
                  <h3 class="line-clamp-2 font-medium playlist-title">
                    {{ item.title }}
                  </h3>
                </div>

                <!-- 歌单创建人信息行 垂直居中 左对齐-->
                <div class="flex flex-row p-2 items-center justify-start">
                  <el-image class="w-8 h-8" :src="defaultCoverImg"></el-image>
                  <h3 class="line-clamp-2 font-medium playlist-title">
                    Seecen Music
                  </h3>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 分页组件 -->
    <nav
      v-if="!isMobile()"
      class="flex w-full justify-center mt-3 mx-auto mb-3"
    >
      <!-- current-page 当前页  page-size 每页多少条  total 总条数
                    size-change 每页显示多少条事件 current-change 当前页码发生变化事件-->
      <el-pagination
        v-bind="pageConfig"
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        @change="handleChange"
      />
    </nav>

    <!-- 新建歌单对话框 -->
    <el-dialog v-model="showNewDialog" title="创建歌单" width="500">
      <!-- 对话框内容部分 -->
      <el-input
        size="large"
        v-model="playlistName"
        placeholder="请输入歌单名称"
      />
      <!-- 对话框底部部分 -->
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showNewDialog = false">取消</el-button>
          <el-button type="primary" @click="handleNewPlaylist">
            创建
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>



<style lang="css" scoped></style>