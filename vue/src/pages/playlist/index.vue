<script setup lang="ts">
// ElementUI icon库
import { Search, VideoPlay } from '@element-plus/icons-vue'
import defaultCoverImg from '@/assets/cover.png'
import { getAllPlaylists, getRecommendedPlaylists } from '@/api/system'
import { isMobile } from '@/utils'
import { RecommendedPlay } from '@/api/interface'
import { ElMessage } from 'element-plus'

// 音乐风格数据
const styleTags = [
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

// 下拉框选择事件
// 当前选中的下拉值
const selectedList = ref('全部')

// 当前页
const currentPage = ref(1)
// 每页显示多少条
const pageSize = ref(10)
// 总数
const total = ref(0)

// 查询参数
const queryParams = ref({
  pageNum: currentPage.value,
  pageSize: pageSize.value,
  // 歌单标题
  title: null,
  // 歌单风格
  style: null,
})
// 歌手搜索变量
const searchKeyword = ref('')

// 搜索歌手名称事件
const handleSearch = async () => {
  // 会有搜索条件 queryParams 需要重置参数
  queryParams.value = {
    pageNum: currentPage.value,
    pageSize: pageSize.value,
    // 歌单标题
    title: searchKeyword.value,
    // 歌单风格
    style: null,
  }
  // 重新查询歌手信息列表
  await getPlayList(queryParams.value)
}

const handleChange = async (currentPage: number, pageSize: number) => {
  // 更新页码与当前页数据
  queryParams.value.pageNum = currentPage
  queryParams.value.pageSize = pageSize
  await getPlayList(queryParams.value)
}

// 定义一个统一配置 让分页组件版内搞定这个配置
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: total.value,
  pageSizes: [10, 15, 20],
})

//
const playListType = ref(['精选歌单', '我的收藏'])
// 推荐歌单
const recommendedPlaylist = ref([])

const getPlayList = async (queryParams: any) => {
  const result = await getAllPlaylists(queryParams)

  if (result.code === 0) {
    recommendedPlaylist.value = result.data.items as RecommendedPlay[]
    pageConfig.total = result.data.total
  } else {
    ElMessage.error('获取歌单失败')
  }
}

onMounted(async () => {
  await getPlayList(queryParams.value)
})
</script>

<template>
  <div class="flex flex-col h-full overflow-auto mx-4 px-4 gap-y-4">
    <!-- 搜索栏 和 下拉框 -->
    <div class="flex flex-row justify-between items-center">
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
          v-for="style in styleTags"
          :key="style.name"
          :label="style.name"
          :value="style.name"
        />
      </el-select>
    </div>

    <!-- 页签 或者 导航栏 -->
    <div class="flex">
      <el-tabs type="border-card" class="w-full overflow-auto">
        <el-tab-pane v-for="item in playListType" :key="item" :label="item">
          <div class="grid grid-cols-3 md:grid-cols-5 gap-4 mt-3">
            <div
              class="rounded-2xl transition duration-300 bg-card cursor-pointer hover:shadow-lg hover:bg-background"
              v-for="item in recommendedPlaylist"
              :key="item.playlistId"
            >
              <!-- 卡片容器 -->
              <div class="p-0">
                <div class="relative">
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
                  <!-- 播放图标 -->
                  <el-icon
                    color="gray"
                    :size="40"
                    class="absolute right-2 bottom-2 z-10"
                    ><VideoPlay
                  /></el-icon>
                </div>

                <!-- 歌单名字 -->
                <div class="flex p-2">
                  <h3 class="line=clamp-2 font-medium playlist-title">
                    {{ item.title }}
                  </h3>
                </div>
                <!-- 歌单创建人 -->
                <div class="flex flex-col p-2 items-center justify-start">
                  <el-image class="w-8 h-8" :src="defaultCoverImg"></el-image>
                  <h3 class="line=clamp-2 font-medium playlist-title">
                    Jar Music
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

