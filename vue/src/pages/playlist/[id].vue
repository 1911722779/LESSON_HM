<script setup lang="ts">
// ElementUI icon库
import { User, VideoPlay } from '@element-plus/icons-vue'
import defaultCoverImg from '@/assets/song.jpg'
import defaultAvatar from '@/assets/user.jpg'
import {
  addPlaylistComment,
  cancelLikeComment,
  getPlaylistDetail,
  likeComment,
} from '@/api/system'
import { ElMessage } from 'element-plus'
import {
  PlaylistComment,
  PlaylistDetail,
  RecommendedPlay,
} from '@/api/interface'
import { isMobile } from '@/utils'
import { useFavoriteStore } from '@/stores/modules/favorite'
import { get } from 'http'
import { isEnumMember } from 'typescript'

// 导入用户缓存
const userStore = UserStore()
// 获取用户名
const currentUsername = computed(() => userStore.userInfo?.username || '')

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

// 默认激活页签
const activeName = ref('歌曲列表')

// 默认规则最热
const isActive = ref('hot')

// 评论
const commentContent = ref('')

// 登录组件
const showLogin = ref(false)

// 发布评论
const handleAddComment = async () => {
  // 1. 校验用户是否登录
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  // 2. 校验内容是否为空值
  if (!commentContent.value.trim()) {
    ElMessage.warning('请输入评论内容')
  }
  // 3. 发布评论 需要知道发布的内容是对应哪个歌单
  // 需要获取歌单id 评论内容
  const playlistId = playlistDetail.value.playlistId
  const result = await addPlaylistComment({
    playlistId,
    content: commentContent.value.trim(),
  })

  if (result.code === 0) {
    ElMessage.success('评论发布成功')
    // 重新获取歌单详情以更新评论列表
    await getDetail(Number(playlistId))
  } else {
    ElMessage.error('评论发布失败')
  }
}

// 点赞与取消点赞
const handleLike = async (comment: PlaylistComment) => {
  // 1. 判断用户是否登录
  if (!userStore.isLoggedIn) {
    ElMessage.warning('请先登录')
    return
  }
  // 2. 点赞/取消赞
  // 2.1 判断当前评论是否已经是点赞状态 是取消赞 不是点赞
  const result = comment.liked
    ? await cancelLikeComment(comment.commentId)
    : await likeComment(comment.commentId)
  if (result.code === 0) {
    ElMessage.success('点赞成功')
    await getDetail(Number(playlistDetail.value.playlistId))
  } else {
    ElMessage.error('取消点赞')
  }
}

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

// 评论列表排序
const handleSort = (type: string) => {
  // 取出评论 作为临时变量排序用
  const tempComments = playlistDetail?.value.comments as PlaylistComment[]
  if (type === 'hot') {
    isActive.value = 'hot'
    // 最热排序 根据点赞数排序
    playlistDetail.value.comments = tempComments?.sort((a, b) => {
      return b.likeCount - a.likeCount
    })
  } else {
    isActive.value = 'new'
    // 最新排序 根据评论时间排序 2025-01-26 ==> 时间毫秒值 数值型
    // 比较器返回值 > 0 b比a大 =0 两数相等 < 0 b比a小
    playlistDetail.value.comments = tempComments?.sort((a, b) => {
      return new Date(b.createTime).getTime() - new Date(a.createTime).getTime()
    })
  }
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
      <div class="flex flex-col justify-between mx-1 md:mx-4 mt-2">
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
            <span class="mx-4">{{ playlistDetail?.songs.length }}首歌曲</span>
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
        :type="isMobile ? '' : 'border-card'"
        class="w-full overflow-auto"
        @tab-click="handleSwitchTab"
      >
        <el-tab-pane label="歌曲列表">
          <!-- PC端显示的曲库组件 -->
          <Table v-if="!isMobile()" :data="playlistDetail?.songs"> </Table>
          <MobileList v-else :data="playlistDetail?.songs"> </MobileList>
        </el-tab-pane>

        <el-tab-pane label="歌单评论">
          <!-- 评论字段 comments 在查询个单的时候 携带数组
            {
              "commentId": 0,
              "username": "string",
              "userAvatar": "string",
              "content": "string",
              "createTime": "string",
              "likeCount": 0,
              "liked": null
            } 
          -->
          <!-- 评论功能 -->
          <!-- 评论列表 -->
          <div class="flex flex-col my-4">
            <div class="flex flex-row gap-x-3 mx-2 mb-2">
              <!-- 显示评论总数 -->
              <h3 class="font-bold mr-4">
                评论总数：{{ playlistDetail?.comments.length ?? 0 }}
              </h3>
              <!-- 评论排序规则 -->
              <button
                :class="[isActive === 'hot' ? 'text-black' : '']"
                @click="handleSort('hot')"
                class="flex hover:text-blue-400 text-gray-500 items-center justify-center"
              >
                最热
              </button>
              <span> | </span>
              <button
                :class="[isActive === 'new' ? 'text-black' : '']"
                @click="handleSort('new')"
                class="flex hover:text-blue-400 text-gray-500 items-center justify-center"
              >
                最新
              </button>
            </div>

            <!-- 评论功能 是需要已经登录才可以评论 没有登录需要提示用户登录 -->
            <div class="flex flex-row gap-x-2">
              <!-- 当前用户头像信息 -->
              <el-avatar
                class="w-12 h-12"
                :src="userStore.userInfo.avatarUrl || defaultAvatar"
              ></el-avatar>

              <!-- 列布局 输入框以及发布按钮 -->
              <div
                class="flex flex-1 flex-col gap-y-3"
                v-if="userStore.isLoggedIn"
              >
                <!-- 输入框 -->
                <el-input
                  v-model="commentContent"
                  maxlength="200"
                  rows="3"
                  show-word-limit
                  placeholder="快来发布你的评论吧~"
                  type="textarea"
                />

                <div class="flex flex-row justify-end">
                  <!-- 发布按钮 无内容时 置灰 :disabled="" -->
                  <el-button
                    @click="handleAddComment"
                    :disabled="!commentContent.trim()"
                    class="w-20 bg-blue-500"
                    type="primary"
                    >发布</el-button
                  >
                </div>
              </div>
              <!-- 未登录的情况 -->
              <div
                class="flex flex-1 gap-y-3 bg-gray-200 justify-center items-center rounded-lg h-14 text-gray-400"
                v-else
              >
                <span>请</span>
                <el-button
                  @click="showLoginDialog"
                  type="primary"
                  size="small"
                  class="w-14"
                  >登录</el-button
                >
                <span>后发布评论喵(๑˃̵ᴗ˂)</span>
              </div>
            </div>

            <!-- 列表渲染 -->
            <div
              class="flex flex-col mt-3"
              v-for="comment in playlistDetail?.comments"
              :key="comment.commentId"
            >
              <div class="flex flex-row">
                <!-- 行布局 头像在左边 个人信息以及评论在右边 -->
                <div>
                  <el-image
                    class="w-12 h-12 rounded-full object-center"
                    :src="comment.userAvatar || defaultAvatar"
                  ></el-image>
                </div>
                <!-- 评论信息部分 -->
                <div class="flex flex-1 flex-col gap-y-4">
                  <!-- 评论人 -->
                  <span class="text-pink-400">{{ comment.username }}</span>
                  <!-- 评论内容 -->
                  <p>{{ comment.content }}</p>
                  <!-- 评论时间与点赞数 -->
                  <div class="flex flex-row">
                    <span class="text-gray-400">{{ comment.createTime }}</span>
                    <!-- 点赞数 图标+点赞总数 如果是自己的评论，显示删除按钮 -->
                    <button
                      @click="handleLike(comment)"
                      class="flex hover:text-blue-400 text-gray-400 items-center justify-center mx-2"
                    >
                      <!-- 点赞图标 -->
                      <icon-material-symbols:thumb-up
                        :class="[
                          comment.liked ? 'text-blue-400' : 'text-gray-400',
                        ]"
                      />
                      <span class="text-gray-400 mx-1">{{
                        comment.likeCount
                      }}</span>
                    </button>

                    <!-- 删除评论功能 -->
                    <button
                      class="flex items-center justify-center"
                      v-if="comment.username === currentUsername"
                    >
                      <!-- 删除图标 -->
                      <icon-material-symbols:delete-outline />
                      <span>删除</span>
                    </button>
                  </div>
                </div>
              </div>

              <!-- 分割线 -->
              <el-divider />
            </div>
          </div>
        </el-tab-pane>
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

