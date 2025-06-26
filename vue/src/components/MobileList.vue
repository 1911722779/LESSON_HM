<script setup lang="ts">
import { UserStore } from '@/stores/modules/user.ts'
import { Song } from '@/api/interface.ts'
import default_album from '@/assets/default_album.jpg'
import { ElMessage } from 'element-plus'
import {
  cancelCollectSong,
  collectSong,
  getAllSongs,
  getFavoriteSongs,
} from '@/api/system.ts'

const audio = AudioStore()
const userStore = UserStore()
const { loadTrack, play } = useAudioPlayer()

const props = defineProps({
  page: {
    type: String,
    required: false,
  },

  data: {
    type: Array,
    required: false,
    default: [],
  },
})

const dataRef = toRef(props, 'data')
// 创建本地副本
const localData: any[] = reactive([])

//无限翻页 自增
const count = ref(0)

// 转换歌曲实体
const convertToTrackModel = (song: Song) => {
  // console.log('原始歌曲数据:', song)
  if (!song.songId || !song.songName || !song.audioUrl) {
    console.error('歌曲数据不完整:', song)
    return null
  }
  return {
    id: song.songId.toString(),
    title: song.songName,
    artist: song.artistName,
    album: song.album,
    cover: song.coverUrl || default_album,
    url: song.audioUrl,
    duration: Number(song.duration) || 0,
    likeStatus: song.likeStatus || 0,
  }
}

interface PageResult {
  items: Song[]
  total: number
}

// 播放音乐
const handlePlay = async (row: Song) => {
  // 先将所有表格数据转换为 trackModel
  const allTracks = localData
    .map((song) => convertToTrackModel(song))
    .filter((track) => track !== null)

  // 找到当前选中歌曲的索引
  const selectedIndex = localData.findIndex(
    (song) => song.songId === row.songId
  )

  // 清空现有播放列表并添加所有歌曲
  audio.setAudioStore('trackList', allTracks)
  // 设置当前播放索引为选中的歌曲
  audio.setAudioStore('currentSongIndex', selectedIndex)
  audio.setAudioStore('lastPlayIndex', selectedIndex)

  // 加载并播放选中的歌曲
  await loadTrack()
  play()
}

// 更新所有相同歌曲的喜欢状态
const updateAllSongLikeStatus = (songId: number, status: number) => {
  // 更新播放列表中的状态
  audio.trackList.forEach((track) => {
    if (Number(track.id) === songId) {
      track.likeStatus = status
    }
  })

  // 更新当前页面的歌曲列表状态
  if (audio.currentPageSongs) {
    audio.currentPageSongs.forEach((song) => {
      if (song.songId === songId) {
        song.likeStatus = status
      }
    })
  }

  // 更新原始数据
  if (localData) {
    const song = localData.find((song) => song.songId === songId)
    if (song) {
      song.likeStatus = status
    }
  }
}

// 处理喜欢/取消喜欢
const handleLike = async (row: Song, e: Event) => {
  e.stopPropagation() // 阻止事件冒泡

  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }

  try {
    if (row.likeStatus === 0) {
      // 收藏歌曲
      const res = await collectSong(row.songId)
      if (res.code === 0) {
        updateAllSongLikeStatus(row.songId, 1)
        ElMessage.success('已添加到我的喜欢')
      } else {
        ElMessage.error(res.message || '添加到我的喜欢失败')
      }
    } else {
      // 取消收藏
      const res = await cancelCollectSong(row.songId)
      if (res.code === 0) {
        updateAllSongLikeStatus(row.songId, 0)
        ElMessage.success('已取消喜欢')
      } else {
        ElMessage.error(res.message || '取消喜欢失败')
      }
    }
  } catch (error: any) {
    ElMessage.error(error.message || '操作失败')
  }
}

// 判断是否是当前播放的歌曲
const isCurrentPlaying = (songId: number) => {
  const currentTrack = audio.trackList[audio.currentSongIndex]
  return currentTrack && Number(currentTrack.id) === songId
}

//无限级 加载数据
const loadData = async () => {
  count.value += 1
  switch (props.page) {
    case 'library': {
      getAllSongs({
        pageNum: count.value,
        pageSize: 20,
      }).then((res) => {
        if (res.code === 0 && res.data) {
          localData.push(...res.data.items)
        }
      })
      break
    }
    case 'like': {
      const res = await getFavoriteSongs({
        pageNum: count.value,
        pageSize: 20,
        songName: '',
        artistName: '',
        album: '',
      })
      if (res.code === 0 && res.data) {
        const pageData = res.data as PageResult
        localData.push(...pageData.items)
        // playlist.value.trackCount = pageData.total
      }
      break
    }
  }
}

onMounted(() => {
  loadData()
  localData.push(...dataRef.value)
})

// 观察数据变化
watch(dataRef, (newData) => {
  localData.push(...newData)
})
</script>

<template>
  <ul v-infinite-scroll="loadData" class="infinite-list" style="overflow: auto">
    <li class="infinite-list-item">
      <!--    移动端适配-->
      <div class="space-y-2">
        <div
          v-for="row in localData"
          :key="row.songId"
          class="flex items-center gap-3 p-2 rounded-xl transition duration-300 cursor-pointer hover:bg-[hsl(var(--hover-menu-bg))]"
          :class="[
            isCurrentPlaying(row.songId)
              ? 'bg-[hsl(var(--hover-menu-bg))]'
              : 'hover:bg-[hsl(var(--hover-menu-bg))]',
            'cursor-pointer',
          ]"
          @click="handlePlay(row)"
        >
          <!-- 歌曲图片 -->
          <div class="relative w-14 h-14 shrink-0">
            <el-image
              :src="row.coverUrl"
              fit="cover"
              lazy
              class="rounded-md w-full h-full"
            />
            <!-- 播放图标覆盖 -->
            <div
              class="absolute inset-0 flex items-center justify-center text-white opacity-0 group-hover:opacity-100 bg-black/40 rounded-md transition-opacity"
            >
              <icon-tabler:player-play-filled class="text-xl" />
            </div>
          </div>

          <!-- 歌曲信息 -->
          <div class="flex-1 overflow-hidden">
            <div class="text-base font-medium truncate">{{ row.songName }}</div>
            <div class="text-sm text-gray-500 truncate">
              {{ row.artistName }}
            </div>
          </div>

          <!-- 喜欢图标 -->
          <div v-show="page == 'library'" class="ml-auto">
            <el-button text circle @click.stop="handleLike(row, $event)">
              <icon-mdi:cards-heart-outline
                v-if="!userStore.isLoggedIn || row.likeStatus === 0"
                class="text-xl"
              />
              <icon-mdi:cards-heart v-else class="text-xl text-red-500" />
            </el-button>
          </div>

          <!--播放图标-->
          <div v-show="page == 'like'" class="ml-auto">
            <el-button text circle>
              <icon-mdi:play-outline class="text-lg" />
            </el-button>
          </div>
        </div>
      </div>
    </li>
  </ul>
</template>

<style scoped></style>
