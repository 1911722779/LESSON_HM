<script setup lang="ts">
import { SongDetail } from '@/api/interface'
import { getFavoriteSongs } from '@/api/system'
import defaultCoverImg from '@/assets/song.jpg'
import { isMobile } from '@/utils'
import { VideoPlay } from '@element-plus/icons-vue'
import { formatTotalTime } from '@/utils/index'

// 导入播放器Store
const audioStore = AudioStore()
//导入播放器 加载播放列表 播放
const { loadTrack, play } = useAudioPlayer()
// 歌曲数据
const songsDetail = ref({
  // 默认收藏封面
  avatar: defaultCoverImg,
  artistName: '我喜欢的音乐',
  songs: [],
  // 播放列表总时长
  totalDuration: 0,
})
// ========================================分页配置================================
// 当前页
const currentPage = ref(1)
//每页显示多少条
const pageSize = ref(10)
// 总数
const total = ref(0)
//搜索变量
const searchKeyWord = ref('')
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
  await getMySongs()
}

//播放全部功能
const handlePlayAll = async () => {
  // 1. 获取当前歌单的歌曲列表
  const songs = songsDetail.value.songs
  //判断歌曲列表是否有歌曲 没有歌曲返回
  if (songs?.length === 0 || !songs) return

  //2. 解析歌曲列表为 播放列表 songs ==> trackList trackModel[]
  const trackList = songs.map(
    ({
      songId,
      songName,
      artistName,
      album,
      coverUrl,
      audioUrl,
      duration,
      likeStatus,
    }) => ({
      id: songId.toString(),
      title: songName,
      artist: artistName,
      album,
      cover: coverUrl,
      url: audioUrl,
      duration,
      likeStatus,
    })
  )

  //3. 将歌曲列表 放入播放列表 头部 并且从第一首歌曲播放
  audioStore.setAudioStore('trackList', trackList)
  audioStore.setAudioStore('currentSongIndex', 0)
  // 加载播放列表
  await loadTrack()
  //播放音乐
  play()
}

const totalDuration = computed(() => {
  const sum = songs.value.reduce(
    (total, song) => total + (Number(song.duration) || 0) / 60,
    0
  )
  return sum.toFixed(2)
})

const songs = ref<SongDetail[]>([])

//获取个人收藏的歌曲列表
const getMySongs = async () => {
  const result = await getFavoriteSongs({
    // 当前页
    pageNum: currentPage.value,
    // 每页显示多少条
    pageSize: pageSize.value,
    //歌曲名称
    songName: searchKeyWord.value,
  })
  if (result.code === 0 && result.data) {
    //获取歌曲列表  item total
    songsDetail.value.songs = result.data.items
    //赋值总数
    pageConfig.total = result.data.total

    if (songsDetail.value.songs.length > 1) {
      // 使用第一个歌曲做封面
      songsDetail.value.avatar = songsDetail.value.songs[0].coverUrl

      //累加歌曲时长 reduce对数组进行累加操作
      //total 上一次累加结果
      songsDetail.value.totalDuration = songsDetail.value.songs.reduce(
        (total, song) => {
          return total + Number(song.duration) || 0
        },
        0
      )

      console.log(songsDetail.value.totalDuration)
    }
  }
}

// 组件创建生命周期函数 初始化数据 获取数据等等
onMounted(() => {
  getMySongs()
})
// 组件被激活时候触发
onActivated(() => {
  getMySongs()
})
// 观察收藏歌曲列表 是否有变化
watch(
  () => songsDetail.value.songs,
  (newSongs) => {
    if (newSongs && newSongs.length > 0) {
      //观察收藏状态 状态改变
      const isChange = newSongs.some((song) => song.likeStatus === 0)
      if (isChange) {
        getMySongs()
      }
    }
  },
  {
    immediate: true,
    deep: true,
  }
)

// 组件卸载之前生命周期
onBeforeUnmount(() => {})
</script>


<template>
  <div class="flex flex-col gap-y-4 h-full px-4 mx-1 md:mx-4 mt-4 p-4">
    <!-- 歌手信息栏  -->
    <div class="flex flex-col md:flex-row w-full">
      <!-- 左边是 歌手头像 -->
      <el-avatar
        :src="songsDetail?.avatar"
        shape="circle"
        class="w-full h-full md:w-60 md:h-60 object-cover shadow-lg"
      >
        <template #placeholder>
          <el-avatar :src="defaultCoverImg"></el-avatar>
        </template>
      </el-avatar>

      <!-- 右边是歌单的信息 歌单名称 歌单的简介 歌单的创建人 与 歌单数量 -->
      <div class="flex flex-col justify-between md:mx-4 mt-2">
        <!-- 歌单信息 列布局 -->
        <div class="flex flex-col gap-y-4">
          <!-- 歌手名称 -->
          <h1 class="text-3xl font-bold line-clamp-2">
            {{ songsDetail?.artistName }}
          </h1>

          <!-- 歌曲播放总时长 -->
          <span class="text-muted-foreground"
            >大约: {{ formatTotalTime(songsDetail?.totalDuration) }}</span
          >

          <!-- 歌曲的数量  xx 首歌曲-->
          <span class="text-muted-foreground"
            >{{ pageConfig.total }} 首歌曲</span
          >
        </div>

        <!-- 歌单信息功能栏行布局 -->

        <div class="flex flex-row gap-x-2">
          <!-- 左侧是 播放全部按钮 带图标  items-center y轴居中 justify-center x轴居中-->
          <button
            @click="handlePlayAll"
            class="bg-blue-500 text-white p-3 rounded-lg inline-flex items-center justify-center gap-x-2 w-48"
          >
            <!--VideoPlay图标 -->
            <el-icon size="30">
              <VideoPlay />
            </el-icon>
            播放全部
          </button>
        </div>
      </div>
    </div>

    <!-- 页签 歌曲列表 -->

    <!-- 页签 或者 导航栏  flex-1 让元素占整个父容器 全部剩余空间 -->
    <div class="flex flex-1">
      <!-- <el-tabs v-model="activeName" :type="isMobile() ? '' : 'border-card'" class="overflow-auto w-full "
                @tab-click="handleSwitchTab"> -->
      <!-- 歌曲列表  -->
      <!-- <el-tab-pane name="歌曲列表" label="歌曲列表"> -->

      <!-- </el-tab-pane> -->

      <!-- </el-tabs> -->

      <!-- PC端显示的曲库组件 -->
      <Table v-if="!isMobile()" :data="songsDetail.songs"></Table>
      <!-- 移动端的曲库组件 -->
      <MobileList v-else :data="songsDetail.songs"></MobileList>
    </div>

    <!-- TODO 分页待做  -->

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
  </div>
</template>



<style lang="css" scoped></style>