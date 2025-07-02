<script setup lang="ts">
// ElementUI icon库
import { VideoPlay } from '@element-plus/icons-vue'
import defaultCoverImg from '@/assets/song.jpg'
import { getArtistDetail } from '@/api/system'
import { ElMessage } from 'element-plus'
import { ArtistDetail, SongDetail } from '@/api/interface'
import { isMobile } from '@/utils'
import 'emoji-picker-element'

// 导入播放器Store
const audioStore = AudioStore()

// 导入播放器 加载播放列表
const { loadTrack, play } = useAudioPlayer()

// 导入播放列表

// 导入路由对象
const route = useRoute()
// 歌手数据
const artistDetail = ref()
// 歌曲列表

// 当前页
// 每页显示多少条

// 默认激活页签
const activeName = ref('歌曲列表')

const songs = ref<SongDetail[]>([])

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

// 获取歌单信息
const getDetail = async (id: number) => {
  const result = await getArtistDetail(id)
  if (result.code === 0) {
    artistDetail.value = result.data as ArtistDetail
    songs.value = artistDetail.value.songs
  } else {
    ElMessage.error('获取歌单详情失败')
  }
}

// 播放全部功能
const handlePlayAll = async () => {
  // 1. 获取当前歌单的歌曲列表
  const songs = artistDetail.value.songs
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
  emitter.on('show-login-dialog', showLoginDialog)
})

// 组件卸载之前生命周期
onBeforeUnmount(() => {
  // 解绑 登录事件总线方法
  emitter.off('show-login-dialog', showLoginDialog)
})

// 调用登录组件
const showLoginDialog = () => {
  emitter.emit('show-login-dialog', { show: true })
}

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
      // 手动激活歌曲列表页签
      activeName.value = '歌曲列表'
      await getDetail(Number(id))
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
      <!-- 左边是 歌手封面 -->
      <el-avatar
        :src="artistDetail?.avatar"
        shape="circle"
        class="w-full h-full md:w-60 md:h-60 object-cover shadow-lg"
      >
        <template #placeholder>
          <el-image :src="defaultCoverImg" />
        </template>
      </el-avatar>

      <!-- 右边是 歌手的详细信息 -->
      <div class="flex flex-col justify-between mx-1 md:mx-4 mt-2">
        <!-- 歌单信息 列布局 -->
        <div class="flex flex-col gap-y-4">
          <!-- 歌手名称 -->
          <h1 class="text-3xl font-bold line-clamp-2">
            {{ artistDetail?.artistName }}
          </h1>
          <!-- 歌手简介 -->
          <p class="text-muted-foreground">
            {{ artistDetail?.introduction }}
          </p>
          <!-- 歌单所属地区 -->
          <span class="text-muted-foreground"
            >地区： {{ artistDetail?.area }}</span
          >
          <!-- 歌手歌曲数量 xx首歌曲 -->
          <span class="mx-4 text-muted-foreground"
            >{{ artistDetail?.songs.length }} 首歌曲</span
          >
        </div>

        <!-- 功能栏列布局 -->
        <div class="flex flex-row gap-x-2">
          <!-- 左侧是 播放全部按钮 带图标 -->
          <button
            @click="handlePlayAll"
            class="bg-blue-400 text-white rounded-lg py-3 px-4 flex items-center justify-center gap-2 w-48"
          >
            <!-- VideoPlay图标 -->
            <el-icon size="30">
              <VideoPlay />
            </el-icon>
            播放全部
          </button>
        </div>
      </div>
    </div>

    <!--页签 歌曲和评论 -->
    <div class="flex flex-1">
      <!-- PC端显示的曲库组件 -->
      <Table v-if="!isMobile()" :data="artistDetail?.songs"> </Table>
      <MobileList v-else :data="artistDetail?.songs"> </MobileList>
      <!-- <el-tabs
        :type="isMobile ? '' : 'border-card'"
        class="w-full overflow-auto"
        @tab-click="handleSwitchTab"
      > -->
        <!-- <el-tab-pane label="歌曲列表"> </el-tab-pane> -->
      <!-- </el-tabs> -->
    </div>

    <!-- 分页 -->


  </div>
</template>

<style lang="css" scoped>
.coverImg > img {
  /* 提升最大优先级 */
  width: 15rem !important;
  height: 15rem !important;
}
</style>

