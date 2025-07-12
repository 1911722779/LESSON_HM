<script setup lang="ts">
import { PlaylistDetail, Song, SongDetail } from '@/api/interface'
import { addSong2Playlist, cancelCollectSong, collectSong, getFavoritePlaylists, getPlaylistDetail, getSongDetail, removeSongFromPlaylist } from '@/api/system'
import defaultCoverImg from "@/assets/cover.png"
import { UserStore } from '@/stores/modules/user'
import { convertToTrackModel, formatMillisecondsToTime, isMobile } from '@/utils'
import { ElMessage } from 'element-plus'
import { computed, PropType, ref, watch } from 'vue'


const emit = defineEmits(['song-removed'])

const audio = AudioStore()
const userStore = UserStore()
const { loadTrack, play } = useAudioPlayer()

const props = defineProps({
  data: {
    type: Array as PropType<Song[]>,
    default: () => [],
  },
  playlistId: {
    type: Number,
    required: false
  }
})

// 监听数据变化，更新当前页面的歌曲列表
watch(
  () => props.data,
  (newData) => {
    audio.setCurrentPageSongs(newData)
  },
  { immediate: true }
)

// 播放音乐
const handlePlay = async (row: Song) => {
  // 先将所有表格数据转换为 trackModel
  const allTracks = props.data
    .map((song) => convertToTrackModel(song))
    .filter((track) => track !== null)

  //添加歌曲到播放列表
  audio.addTracks(allTracks)
  // 从播放列表 找到当前选中歌曲的索引
  const selectedIndex = audio.trackList.findIndex(
    (song) => song.id === row.songId.toString()
  )

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
    audio.currentPageSongs.forEach((song: any) => {
      if (song.songId === songId) {
        song.likeStatus = status
      }
    })
  }

  // 更新原始数据
  if (props.data) {
    const song = props.data.find((song) => song.songId === songId)
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

const downLoadMusic = (row: Song, e: Event) => {
  e.stopPropagation() // 阻止事件冒泡
  const link = document.createElement('a')
  link.href = row.audioUrl
  link.setAttribute('download', `${row.songName} - ${row.artistName}`)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// 判断是否是当前播放的歌曲
const isCurrentPlaying = (songId: number) => {
  const currentTrack = audio.trackList[audio.currentSongIndex]
  return currentTrack && Number(currentTrack.id) === songId
}

// ==================== 更多操作相关 ====================

// 用户歌单列表
const userPlaylists = ref<any[]>([])
// 搜索歌单关键词
const playlistSearchKeyword = ref('')

// 获取用户歌单列表
const getUserPlaylistList = async () => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  try {
    const res = await getFavoritePlaylists({
      pageNum: 1,
      pageSize: 50,
      title: '',
      style: ''
    })
    if (res.code === 0 && res.data) {
      userPlaylists.value = res.data.items || []
    }


  } catch (error) {
    ElMessage.error('获取歌单列表失败')
  }
}

// 过滤歌单列表
const filteredPlaylists = computed(() => {
  return userPlaylists.value.filter(playlist => {
    const matchKeyword = !playlistSearchKeyword.value ||
      playlist.title.toLowerCase().includes(playlistSearchKeyword.value.toLowerCase())
    const matchOwner = playlist.createBy === userStore.userInfo.userId
    return matchKeyword && matchOwner
  })
})


// 添加歌曲到歌单
const addToPlaylist = async (songId: number, playlistId: number) => {
  if (!songId) return

  try {
    const res = await addSong2Playlist(songId, playlistId)
    if (res.code === 0) {
      ElMessage.success('添加成功')

    } else {
      ElMessage.error(res.message || '添加失败')
    }

    playlistSearchKeyword.value = ''
  } catch (error: any) {
    ElMessage.error(error.message || '添加失败')
  }
}

// 从歌单中删除歌曲
const route = useRoute()
watch(
  () => route.params.id,
  async (id: string) => {

    if (id) {
      // console.log("我是id1", typeof(Number(route.params.id)))
      // console.log("user:", UserStore().userInfo.userId)
      const result = await getPlaylistDetail(Number(id))
      playlistDetail.value = result.data as PlaylistDetail
      // console.log("data:", result.data?.createBy)
      // console.log("userid:",typeof(UserStore().userInfo.userId));
      // console.log("props.playlistId:", typeof (props.playlistId))
      // console.log("playlist111", playlistDetail.value);
      await getDetail(Number(id))

    }
  },
  {
    // 是否立即通知 立即观察
    immediate: true,
    // 是否深度观察 有一些观察对象 可能是复杂对象 {name:zhangsan,hobby:{ }} 0x16e 0x18d
    deep: true,
    // 是否只观察一次 ,页面加载一次  用户首次登录 
    // once:true
  }
)
// 设为私人
const isPrivate = ref(0)
// 歌曲列表
const songs = ref<SongDetail[]>([])
// 获取歌单信息
const getDetail = async (id: number) => {
  const result = await getPlaylistDetail(id)
  if (result.code === 0) {
    // 歌单详情 携带 评论列表 以及 歌单附属歌曲列表
    playlistDetail.value = result.data as PlaylistDetail
    // console.log("songs111", songs.value)
    songs.value = playlistDetail.value.songs
    isPrivate.value = playlistDetail.value.isPrivate
  } else {
    ElMessage.error("获取歌单详情失败")
  }
}

// 接收父组件数据


// 歌单数据
const playlistDetail = ref()

// 删除歌曲
const handleRemoveFromPlaylist = async (songId: number, e: Event) => {
  e.stopPropagation() // 阻止事件冒泡
  const res = await removeSongFromPlaylist(Number(route.params.id), songId)
  if (res.code === 0) {
    ElMessage.success('删除成功')
    isDeleteDialogVisible.value = false
    // 通知父组件 刷新歌单信息 
    emit('song-removed', songId)
  } else {
    ElMessage.error(res.message || '删除失败')
  }
}

const isDeleteDialogVisible = ref(false)
const openDeleteDialog = (song: Song) => {
  console.log("我出发了");
  songToDelete.value = song
  // 显示对话框
  isDeleteDialogVisible.value = true

}
const resetDialog = () => {
  isDeleteDialogVisible.value = false
}
const songToDelete = ref<Song | null>(null)

const confirmDelete = async (row: Song, $event: Event) => {
  console.log("songid:", row.songId, "playlistid:", route.params.id)

  // if (!songToDelete.value) {
  //   console.log("songid:", row.songId, "playlistid:", route.params.id)
  //   return
  // }
  await handleRemoveFromPlaylist(row.songId, $event)
  resetDialog()
}
defineExpose({ openDeleteDialog })


</script>

<template>
  <!--    PC端-->
  <el-table :data="data" v-if="!isMobile()" style="
      --el-table-border: none;
      --el-table-border-color: none;
      --el-table-tr-bg-color: none;
      --el-table-header-bg-color: none;
      --el-table-row-hover-bg-color: transparent;
    " class="!rounded-lg !h-full transition duration-300 overflow-x-auto">
    <!-- 插槽 选择框 -->
    <el-table-column type="selection" width="55">
    </el-table-column>
    <el-table-column>
      <template #header>
        <div
          class="grid grid-cols-[auto_4fr_3fr_3fr_1fr_2fr_1fr_1fr] items-center gap-6 w-full text-left mt-2 overflow-x-auto">
          <div class="ml-3">标题</div>
          <div class="w-12"></div>
          <div class="ml-1">歌手</div>
          <div>专辑</div>
          <div>喜欢</div>
          <div class="ml-7">时长</div>
          <div>下载</div>
          <div>更多</div>
        </div>
      </template>
      <template #default="{ row }">
        <div
          class="grid grid-cols-[auto_4fr_3fr_3fr_1fr_2fr_1fr_1fr] items-center gap-6 w-full group transition duration-300 rounded-2xl p-2"
          :class="[
            isCurrentPlaying(row.songId)
              ? 'bg-[hsl(var(--hover-menu-bg))]'
              : 'hover:bg-[hsl(var(--hover-menu-bg))]',
            'cursor-pointer',
          ]" @click="handlePlay(row)">
          <!-- 标题和封面 -->
          <div class="w-10 h-10 relative">
            <el-image :src="row.coverUrl || defaultCoverImg" lazy :alt="row.songName" class="w-full h-full rounded-md">
              <template #placeholder>
                <el-image :src="defaultCoverImg" />
              </template>
            </el-image>
            <!-- Play 按钮，使用 group-hover 控制透明度 -->
            <div
              class="absolute inset-0 flex items-center justify-center text-white opacity-0 transition-opacity duration-300 z-10 group-hover:opacity-100 group-hover:bg-black/50 rounded-md">
              <icon-tabler:player-play-filled class="text-lg" />
            </div>
          </div>

          <!-- 歌曲名称 -->
          <div class="text-left">
            <div class="flex-1 line-clamp-1">{{ row.songName }}</div>
          </div>

          <!-- 歌手 -->
          <div class="text-left">
            <div class="line-clamp-1 w-48">{{ row.artistName }}</div>
          </div>

          <!-- 专辑 -->
          <div class="text-left">{{ row.album }}</div>

          <!-- 喜欢 -->
          <div class="flex items-center ml-1">
            <el-button text circle @click="handleLike(row, $event)">
              <icon-mdi:cards-heart-outline v-if="!userStore.isLoggedIn || row.likeStatus === 0" class="text-lg" />
              <icon-mdi:cards-heart v-else class="text-lg text-red-500" />
            </el-button>
          </div>

          <!-- 时长 -->
          <div class="text-left ml-8">
            <span>{{
              formatMillisecondsToTime(Number(row.duration) * 1000)
            }}</span>
          </div>

          <!-- 下载 -->
          <div class="flex items-center ml-1">
            <el-button text circle @click.stop="downLoadMusic(row, $event)">
              <icon-material-symbols:download class="text-lg" />
            </el-button>
          </div>

          <!-- 更多操作 -->
          <div class="flex items-center ml-1">
            <el-dropdown :hide-on-click="false" trigger="click" placement="bottom-start">
              <el-button text circle @click.stop="getUserPlaylistList">
                <icon-material-symbols:more-horiz class="text-xl" />
              </el-button>
              <template #dropdown>
                <el-dropdown-item class="flex flex-col w-48">
                  <el-popover :popper-class="['custom-popover']" :show-arrow="false" width="250"
                    :popper-append-to-body="false" class="flex flex-col text-lg" title="请选择添加歌单" placement="left-start">

                    <template #reference>
                      <div class="flex flex-row h-12 items-center">
                        <icon-material-symbols:playlist-add class="mr-2" />
                        添加到歌单
                      </div>
                    </template>

                    <div class="flex flex-col overflow-x-auto">

                      <el-input v-model="playlistSearchKeyword" placeholder="搜索歌单" size="small" class="text-sm w-48 h-8"
                        @input.stop @compositionstart.stop @compositionend.stop @click.stop.prevent>
                        <template #prefix>
                          <icon-material-symbols:search class="text-sm" />
                        </template>
                      </el-input>

                      <!-- 歌单列表 -->
                      <div v-for="playlist in filteredPlaylists" :key="playlist.playlistId"
                        @click="addToPlaylist(row.songId, playlist.playlistId)"
                        class="p-0 flex flex-row hover:text-blue-500 cursor-pointer">
                        <div class="flex items-center py-1 ">
                          <el-image :src="playlist.coverUrl || defaultCoverImg" class="w-6 h-6 rounded " />
                          <span class="truncate">{{ playlist.title }}</span>
                        </div>
                      </div>
                      <!-- 没有歌单时的提示 -->
                      <div v-if="filteredPlaylists.length === 0" disabled>
                        <span class="text-gray-400">暂无歌单</span>
                      </div>

                    </div>
                  </el-popover>

                </el-dropdown-item>

                <el-button class="w-48 h-10" type="danger" @click="isDeleteDialogVisible = true"
                  v-if="userStore.userInfo.userId === playlistDetail?.createBy">
                  <div class="flex flex-row items-center text-red-500">
                    <icon-material-symbols:delete class="mr-2" />
                    从歌单中删除
                  </div>
                </el-button>
                <el-dialog title="确认删除" v-model="isDeleteDialogVisible" width="400px">
                  <span>你确定要从歌单中删除这首歌曲吗？</span>
                  <template #footer>
                    <div class="dialog-footer">
                      <el-button @click="isDeleteDialogVisible = false">取消</el-button>
                      <el-button type="primary" @click="confirmDelete(row, $event)">确定</el-button>
                    </div>
                  </template>

                </el-dialog>
              </template>
            </el-dropdown>
          </div>
        </div>
      </template>
    </el-table-column>
  </el-table>


</template>

<style scoped>
:deep(.el-table__row) {
  background: transparent !important;
}

:deep(.el-table__row:hover) td {
  background: transparent !important;
}

:deep(.el-table__cell) {
  padding: 0 !important;
}

.custom-popover {
  position: absolute !important;
  transform: translate3d(0, 0, 0) !important;
}
</style>
