<script setup lang="ts">
// ElementUI icon库
import { Search } from '@element-plus/icons-vue'
import defaultCoverImg from '@/assets/cover.png'
import {
  getRecommendedPlaylists,
  getAllPlaylists as fetchAllPlaylists,
} from '@/api/system'
import { isMobile } from '@/utils'
import { RecommendedPlay } from '@/api/interface'
import { ElMessage } from 'element-plus'

// 歌单搜索变量
const searchKeyword = ref('')

// 歌单列表数组
const playList = ref([])

// 控制当前激活的 tab
const activeTab = ref('recommended') // 默认显示 "精选歌单"

// 精选歌单
const recommendedPlaylist = ref([])
const allPlayists = ref([])

const queryParams = ref({
  pageNum: 1,
  pageSize: 1,
  // 歌单标题
  title: '',
  // 歌单风格
  style: '',
})
// 查询数据库中有哪些歌单
const getAllPlaylists = async () => {
  try {
    const res = await fetchAllPlaylists(queryParams.value)

    if (res.code === 0 && res.data) {
      playList.value = res.data.items
    } else {
      console.error('获取歌单列表失败', res.message)
    }
  } catch (error) {
    console.error('获取歌单列表失败', error)
  }
}

// 搜索歌单名称事件
const handleSearch = async () => {
  // 会有搜索条件 queryParams 需要重置参数
  queryParams.value = {
    pageNum: 1,
    pageSize: 1,
    // 歌单标题
    title: '',
    // 歌单风格
    style: '',
  }
  queryParams.value.title = searchKeyword.value
  queryParams.value.pageNum = 1 // 回到第一页
  // 重新查询歌手信息列表
  await getAllPlaylists()
}

// 下拉框选择事件
// 当前选中的下拉值
const selectedList = ref('全部') // 默认全部

// 音乐风格数据
const musicStyles = [
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
]

// 获取精选歌单
const getRecommendData = async () => {
  
  // 发送网络请求 获取推荐歌单
  const result = await getRecommendedPlaylists()
  // 判断成功与否 还需要判断一下是否是数组类型
  if (result.code === 0 && Array.isArray(result.data)) {
    // 返回对象数据 存在本地变量 让for循环变量
    // 写法1 偷懒写法 不用定义类型
    // recommendedPlaylist.value = result.data.map((item) => ({
    //   playlistId:item.playlistId,
    //   title:item.title,
    //   coverUrl:item.coverUrl
    // }))

    // 写法2 规范写法 定义类型 让result.data 转为这个对象类型
    recommendedPlaylist.value = result.data as RecommendedPlay[]
    // 打印结果
    console.log(recommendedPlaylist.value)
  } else {
    ElMessage.error('获取推荐歌单失败')
  }
}

// 当前页
const currentPage = ref(1)
// 每页显示多少条
const pageSize = ref(20)
// 总数
const total = ref(10)
// 页码 与 当前页 变更事件
/**
 * currentPage: number, pageSize: number
 * @param currentPage
 * @param pageSize
 */
const handleChange = async (currentPage: number, pageSize: number) => {
  // 更新页码与当前页数据
  queryParams.value.pageNum = currentPage
  queryParams.value.pageSize = pageSize
  await getAllPlaylists()
}

// 定义一个统一配置 让分页组件版内搞定这个配置
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: recommendedPlaylist.value.length,
  pageSizes: [20, 30, 40],
})

onMounted(async () => {
  await getAllPlaylists()
  await getRecommendData()
})
</script>

<template>
  <!-- 
    flex 弹性布局
    flex-col 列布局
    flex-2 2列
    h-full 高度100%
    overflow-hidden 溢出隐藏 
  -->
  <div class="flex flex-col flex-1 overflow-hidden">
    <!-- 搜索栏 和 下拉框 -->
    <div class="flex flex-row justify-between items-center items-top ml-3 mb-4">
      <!-- 复合型输入框 左边有一个icon 右边是输入框
          @keyup.enter="handleSearch" 按下回车键时触发 
        -->
      <el-input
        class="w-1/5 ml-4"
        @keyup.enter="handleSearch"
        v-model="searchKeyword"
        size="large"
        placeholder="搜索歌单"
        :prefix-icon="Search"
      />
      <!-- 下拉框 -->
      <el-select class="w-1/5 mr-4" v-model="selectedList">
        <el-option
          v-for="style in musicStyles"
          :key="style.name"
          :label="style.name"
          :value="style.name"
        />
      </el-select>
    </div>

    <!-- 歌单展示 -->
    <div class="ml-3 mr-3 mt-6">
      <!-- 标题 布局两端对齐 -->
      <div class="flex justify-between items-center">
        <!-- 左边 -->
        <div class="inline-flex rounded-lg bg-gray-100 p-1 shadow-sm">
          <button
            @click="activeTab = 'recommended'"
            :class="[
              'px-4 py-2 text-sm font-medium rounded-md transition',
              activeTab === 'recommended'
                ? 'bg-white text-blue-600 shadow'
                : 'text-gray-600 hover:text-gray-900',
            ]"
          >
            精选歌单
          </button>
          <button
            @click="activeTab = 'favorite'"
            :class="[
              'px-4 py-2 text-sm font-medium rounded-md transition',
              activeTab === 'favorite'
                ? 'bg-white text-blue-600 shadow'
                : 'text-gray-600 hover:text-gray-900',
            ]"
          >
            我的收藏
          </button>
        </div>
      </div>

      <!-- 精选歌单 内容 
            上下结构的卡片 内容展示 行布局  以网格布局为主
            grid 网格布局
            grid-cols-3 默认3个
            gap-4 间距4
          -->
      <div v-if="activeTab === 'recommended'" 
        class="grid grid-cols-4 md:grid-cols-5 gap-4 mt-3">
        <!-- 
                rounded-2xl 圆角
                transition
                duration-300 动画持续300ms
                bg-card text-card 背景卡片 文本卡片
                cursor-pointer 鼠标样式
              -->
        <div
          class="rounded-2xl transition duration-300 bg-card cursor-pointer"
          v-for="item in recommendedPlaylist"
          :key="item.playlistId"
        >
          <div class="p-0">
            <!-- 歌单封面 -->
            <el-image
              :src="item.coverUrl"
              width="200"
              height="200"
              loading="lazy"
              class="w-full h-full object-cover rounded-t-2xl overflow-hidden"
            >
              <!-- 占位内容，加载比较慢的情况下 默认先贴一张静态图显示 -->
              <template #placeholder>
                <el-image :src="defaultCoverImg" />
              </template>
            </el-image>
            <!-- 歌单名字 -->
            <div class="flex flex-col p-2">
              <h3 class="line=clamp-2 font-medium playlist-title">
                {{ item.title }}
              </h3>
            </div>
          </div>
        </div>
      </div>

      <!-- 我的收藏歌单 内容 -->
      <div v-if="activeTab === 'favorite'" 
        class="text-center py-8 text-gray-500">
        <el-empty description="您还没有收藏歌单" />
      </div>
    </div>

    <!-- 分页组件 -->
      <nav
        v-if="!isMobile()"
        class="flex w-full justify-center mt-3 mx-auto mb-3"
      >
        <!-- current-page 当前页 page-size 每页多少条 total 总条数 sizi-change 每页显示多少条事件 -->
        <el-pagination
          v-bind="pageConfig"
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          @change="handleChange"
        />
      </nav>
  </div>
</template>

<style lang="css" scoped>
:deep(.el-input__wrapper) {
  border-radius: 10px;
}

</style>

