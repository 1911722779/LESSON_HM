<script setup lang="ts">
// ElementUI icon库
import { VideoPlay } from '@element-plus/icons-vue'
import defaultCoverImg from '@/assets/song.jpg'
import { getPlaylistDetail } from '@/api/system'
import { ElMessage } from 'element-plus'
import { PlaylistDetail, RecommendedPlay } from '@/api/interface'
import { isMobile } from '@/utils'
import { useFavoriteStore } from '@/stores/modules/favorite'

// 导入收藏Store
const favoriteStore = useFavoriteStore()

// 导入播放器Store
const audioStore = AudioStore()

// 导入播放器 加载播放列表
const { loadTrack, play } = useAudioPlayer()

// 导入播放列表
const playlistStore = usePlaylistStore()

// 导入路由对象
const route = useRoute()
// 歌单数据
const playlistDetail = ref()
// 歌曲列表
const songs = reactive([])

// 歌单页签数组
const playListType = ref(['歌单', '评论'])

// 当前页
const currentPage = ref(1)
// 每页显示多少条
const pageSize = ref(10)

// 查询参数
const queryParams = ref({
  pageNum: currentPage.value,
  pageSize: pageSize.value,
  // 歌单标题
  title: null,
  // 歌单风格
  style: null,
})

// 切换页签事件
const handleSwitchTab = async (name: any) => {
  // ElMessage.info(name.label)
  // console.log(name.props.label)
  // 当前页签名称
  const currentTab = name.props.label
  if (currentTab === '歌曲列表') {
  } else {
  }
}

// 切换收藏状态
const toggleLike = async () => {
  if (playlistDetail.value.likeStatus === 1) {
    // 取消收藏
    await favoriteStore.cancelCollectPlaylist(playlistDetail.value.playlistId)
  } else {
    // 收藏
    await favoriteStore.collectPlaylist(playlistDetail.value.playlistId)
  }
  await getDetail(playlistDetail.value.playlistId)
}

// 获取歌单信息
const getDetail = async (id: number) => {
  const result = await getPlaylistDetail(id)
  if (result.code === 0) {
    playlistDetail.value = result.data as PlaylistDetail
  } else {
    ElMessage.error('获取歌单详情失败')
  }
}

// 播放全部功能
const handlePlayAll = async () => {
  // 1. 获取当前歌单的歌曲列表
  const songs = playlistDetail.value.songs
  // 判断歌单中是否存在歌曲
  if (songs?.length === 0 || !songs) return

  // 2. 解析歌曲列表为 播放列表 songs ==> trackList trackModel[]
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

  // 3. 将歌曲列表 放入播放列表 头部 并且从第一首歌曲开始播放
  audioStore.setAudioStore('trackList', trackList)
  audioStore.setAudioStore('currentSongIndex', 0)
  // 加载播放列表
  await loadTrack()
  // 播放
  play()
}

// 组件创建生命周期函数 初始化数据 获取数据等
onMounted(async () => {
  // 获取上一个页面传递过来的参数 只获取一次
})

// 监听函数 watch 动态监听 只要有参数变化 就会监听变换过程
/**
 * source: WatchSource<unknown>, 数据源 观察源
 * db: WatchCallback<unknown>, 监听回调函数 只要数据源变化 就会将数据传递给回调函数
 *  options?: WatchOptions<false> 监听选项
 */
watch(
  () => route.params.id,
  async (id: string) => {
    // console.log(id)
    // 获取歌单详情信息
    if (id) {
      const result = await getPlaylistDetail(Number(id))
      if (result.code === 0) {
        // 歌单详情 携带 评论列表 以及 歌单附属歌曲列表
        // console.log(result.data)
        playlistDetail.value = result.data as PlaylistDetail
        console.log(playlistDetail.value.songs)
        songs.push(...playlistDetail.value.songs)
      } else {
        ElMessage.error('获取歌单详情失败')
      }
    }
  },
  {
    // 是否立即通知
    immediate: true,
    // 是否深度观察 有一些观察对象 可能是复杂对象 默认不会观察到对象内部的变化
    deep: true,
    // 是否只观察一次，页面加载一次 用户首次登录
    // once:true
  }
)
</script>

<template>
  <div class="flex flex-col gap-y-4 h-full px-4 mx-1 md:mx-4 mt-4 p-4">
    <!-- 歌曲信息栏 -->
    <div class="flex flex-col md:flex-row w-full">
      <!-- 左边是 歌单封面 -->
      <el-image
        :src="playlistDetail?.coverUrl"
        class="w-full h-full md:w-60 md:h-60 roundned-lg object-cover shadow-lg"
      >
        <template #placeholder>
          <el-image :src="defaultCoverImg" />
        </template>
      </el-image>

      <!-- 右边是 歌单的详细信息 歌单名称 歌单简介 歌单创建人 歌单数量 -->
      <div class="flex flex-col justify-between  mx-1 md:mx-4 mt-2">
        <!-- 歌单信息 列布局 -->
        <div class="flex flex-col gap-y-4">
          <!-- 歌单名称 -->
          <h1 class="text-3xl font-bold line-clamp-2">
            {{ playlistDetail?.title }}
          </h1>
          <!-- 歌单简介 -->
          <p class="text-muted-foreground">
            {{ playlistDetail?.introduction }}
          </p>
          <!-- 歌单创建人 以及 歌单数量 行布局 -->
          <div class="flex flex-row items-center">
            <!-- 行布局左侧 歌单创建人头像 -->
            <el-image
              :src="defaultCoverImg"
              class="w-12 h-12 rounded-full object-cover"
            >
              <template #placeholder>
                <el-image :src="defaultCoverImg" />
              </template>
            </el-image>
            <!-- 歌单创建人 名字 -->
            <span>Jar Music</span>
            <!-- 歌单歌曲数量 xx首歌曲 -->
            <span>{{ playlistDetail?.songs.length }}</span>
          </div>
        </div>

        <!-- 功能栏列布局 -->
        <div class="flex flex-row gap-x-2">
          <!-- 左侧是 播放全部按钮 带图标 -->
          <button
            @click="handlePlayAll"
            class="bg-blue-400 text-white rounded-lg p-3 inline-flex items-center gap-x-2 w-48 justify-center"
          >
            <!-- VideoPlay图标 -->
            <el-icon size="30">
              <VideoPlay />
            </el-icon>
            播放全部
          </button>
          <!-- 右侧是 喜欢按钮 也是图标 -->
          <button
            @click="toggleLike"
            class="bg-gray-200 rounded-lg p-3 inline-flex items-center justify-center gap-x-2 w-16"
          >
            <!-- 喜欢图标 -->
            <icon-ic:round-favorite
              v-if="playlistDetail?.likeStatus === 1"
              class="text-2xl text-red-500"
            />
            <icon-ic:round-favorite-border v-else class="text-2xl text-white" />
          </button>
        </div>
      </div>
    </div>

    <!--页签 歌曲和评论 -->
    <div class="flex flex-1">
      <el-tabs
        :type="isMobile?'':'border-card'"
        class="w-full overflow-auto"
        @tab-click="handleSwitchTab"
      >
        <el-tab-pane label="歌曲列表">
          <!-- PC端显示的曲库组件 -->
          <Table v-if="!isMobile()" :data="playlistDetail?.songs"> </Table>
          <MobileList v-else :data="playlistDetail?.songs"> </MobileList>
        </el-tab-pane>

        <el-tab-pane label="歌单评论"> </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<style lang="css" scoped>
.coverImg > img {
  /* 提升最大优先级 */
  width: 15rem !important;
  height: 15rem !important;
}
</style>

