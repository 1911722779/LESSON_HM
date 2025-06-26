<script setup lang="ts">
import { RecommendedPlay, SongDetail } from '@/api/interface'
import {
  getBanner,
  getRecommendedPlaylists,
  getRecommendedSongs,
} from '@/api/system'
import { UserStore } from '@/stores/modules/user'
import { ElMessage } from 'element-plus'
import defaultCoverImg from '@/assets/cover.png'
import { isMobile, formatTime } from '@/utils'
import { trackModel } from '@/stores/interface'

const router = useRouter()
const audio = AudioStore()
const user = UserStore()

const { loadTrack, play } = useAudioPlayer()
// 轮播图
const bannerList = ref<{ bannerId: number; bannerUrl: string }[]>([])

// 推荐歌单
const recommendedPlaylist = ref([])
// 推荐歌曲
const recommendedSongList = ref([])

const carouselType = ref<'card' | ''>()

// 获取轮播图
const getBannerData = async () => {
  // 发送网络请求 获取轮播图
  const result = await getBanner()
  // 判断成功与否 还需要判断一下是否是数组类型
  if (result.code === 0 && Array.isArray(result.data)) {
    // 将返回数据 存在本地变量 让for循环变量
    bannerList.value = result.data
  } else {
    ElMessage.error('获取轮播图失败')
  }
}

// 获取推荐歌单
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

// 获取歌曲列表
const getSongList = async () => {
  // 1. 发送网络请求到后台 获取相似歌曲列表
  const result = await getRecommendedSongs()
  if (result.code === 0 && Array.isArray(result.data)) {
    // 2. 解析数据
    // console.log(result.data)
    // 3. 填充数据
    recommendedSongList.value = result.data as SongDetail[]
    console.log(recommendedSongList.value)
  }
}

// 播放音乐
const handlePlayMusic = async (music: SongDetail) => {
  // 播放歌曲 将播放的歌曲添加到 歌曲列表
  const songs = recommendedSongList.value

  const trackList: trackModel[] = songs.map((song: SongDetail) => ({
    id: song.songId.toString(),
    title: song.songName,
    artist: song.artistName,
    album: song.album,
    cover: song.coverUrl,
    url: song.audioUrl,
    duration: song.duration,
    likeStatus: song.likeStatus,
  }))

  // 添加到待播放列表
  audio.setAudioStore('trackList', trackList)
  // 设置当前播放的歌曲 替换成music
  const index = songs.findIndex((song) => song.songId === music.songId)
  // 设置当前播放音乐索引
  audio.setAudioStore('currentSongIndex', index)
  // 音乐播放器加载播放列表
  await loadTrack()
  // 播放音乐
  play()
}

// 声明周期函数 组件创建后
onMounted(async () => {
  await getBannerData()
  await getRecommendData()
  await getSongList()
})
</script>

<template>
  <!-- 
      flex 弹性布局 
      gap-6 间距24px 
      p-4 所有元素16px内填充 
      w-full 100%宽度 
      
    -->
  <div class="flex gap-6 p-4 w-full">
    <div class="flex-1">
      <div class="w-full flex flex-col overflow-hidden mb-8">
        <!-- 轮播图 -->
        <el-carousel
          card-scale="0.83"
          :type="!isMobile() ? 'card' : ''"
          :height="!isMobile() ? '300px' : '160px'"
        >
          <el-carousel-item v-for="item in bannerList" :key="item.bannerId">
            <!-- 轮播的图片 -->
            <el-image class="rounded-lg" :src="item.bannerUrl" />
          </el-carousel-item>
        </el-carousel>

        <!-- 今日推荐 -->
        <div class="mt-6">
          <!-- 标题 布局两端对齐 -->
          <div class="flex justify-between items-center">
            <!-- 左边 -->
            <h2 class="text-xl font-semibold">今日为你推荐</h2>
            <!-- 右边 
             justify-center 主轴居中
             items-center 元素居中
            -->
            <button
              class="inline-flex items-centere justify-center gap-2 text-sm text-gray-500"
            >
              <icon-hugeicons:more class="text-lg" />
              更多
            </button>
          </div>

          <!-- 推荐歌单 内容 
            上下结构的卡片 内容展示 行布局  以网格布局为主
            grid 网格布局
            grid-cols-3 默认3个
            gap-4 间距4
          -->
          <div class="grid grid-cols-3 md:grid-cols-5 gap-4 mt-3">
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
        </div>
        <!-- 相似歌曲推荐 -->
        <div class="w-full mt-6">
          <!-- 标题 布局两端对齐 -->
          <div class="flex justify-between items-center">
            <!-- 左边 -->
            <h2 class="text-xl font-semibold">相似推荐</h2>
            <!-- 右边 
             justify-center 主轴居中
             items-center 元素居中
            -->
            <button
              class="inline-flex items-center justify-center gap-2 text-sm text-gray-500"
            >
              <!-- 左侧图标 -->
              <icon-tabler:refresh class="text-lg" />
              刷新
            </button>
          </div>

          <!-- 
            1. 使用玩个够布局 PC端 2列 移动端 1列
            2. 支持上下滑动
          -->
          <el-scrollbar class="w-full">
            <!-- 网格布局 样式 手机端 1列 PC端 2列 间距16px 列间距 48px -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 gap-x-12">
              <!-- grid-cols-[auto_2fr_1fr] 默认散列 auto 第1列 自动宽度 2fr 占剩余空间的2份 1fr 占剩余空间的1份 -->
              <button
                v-for="item in recommendedSongList"
                :key="item"
                @click="handlePlayMusic(item)"
                class="grid grid-cols-[auto_2fr_1fr] items-center w=-full rounded=2xl"
              >
                <!-- 专辑封面 -->
                <el-image class="rounded-2xl w-16 h-16" :src="item.coverUrl">
                  <!-- 占位内容，加载比较慢的情况下 默认先贴一张静态图显示 -->
                  <template #placeholder>
                    <el-image :src="defaultCoverImg" />
                  </template>
                </el-image>
                <!-- 歌曲信息 -->
                <!-- text-left 文本左对齐 左外边距4px  -->
                <div class="text-left ml-1">
                  <!-- 歌曲名称 -->
                  <h3 class="font-medium">{{ item.songName }}</h3>
                  <!-- 歌曲作者 text-muted-foreground 次要文字颜色 -->
                  <p class="text-sm text-muted-foreground line-clamp-1">
                    {{ item.artisName }}
                  </p>
                </div>

                <!-- 歌曲时长 后台给的单位是秒 -->
                <!-- text-right 文本右对齐 右外边距20px text-muted-foreground 次要文字颜色 -->
                <div class="text-right mr-5">
                  <p class="text-sm text-muted-foreground line-clamp-1">
                    {{ formatTime(item.duration) }}
                  </p>
                </div>
              </button>
            </div>
          </el-scrollbar>
        </div>
      </div>
    </div>
  </div>
</template>


<style scoped>
/* 定制化轮播图 去掉指示器 */
:deep(.el-carousel__indicator) {
  display: none;
}

/* 隐藏 Mask */
:deep(.el-carousel__mask) {
  display: none;
}

:deep(.el-carousel__item) {
  --el-carousel-item-scale: 1.2;
  /* 默认是 0.83，可以调整 */
}

/**
移动端 不显示 指示器

 */
@media screen and (max-width: 768px) {
  :deep(.el-carousel__indicator) {
    display: none;
  }
}

/* 让所有图片撑满 */
.el-carousel__item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 20px;
  /* 圆角 */
}

.playlist-title {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  text-align: left;
  min-height: 2.5em;
  /* 固定两行高度 */
  line-height: 1.25;
  /* 行高 */
  overflow: hidden;
  text-overflow: ellipsis;
  display: flex;
  align-items: center;
  /* 单行时垂直居中 */
}
</style>
