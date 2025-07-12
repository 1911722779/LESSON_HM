<script setup lang="ts">
import { PlaylistComment, PlaylistDetail, Song, SongDetail } from "@/api/interface";
import { addPlaylistComment, addSong2Playlist, cancelLikeComment, deleteComment, getAllSongs, getFavoritePlaylists, getPlaylistDetail, likeComment, removeSongFromPlaylist, updatePlaylist, updatePlaylistAvatar } from "@/api/system";
import defaultCoverImg from "@/assets/song.jpg";
import defaultAvatar from "@/assets/user.jpg";
import { useFavoriteStore } from "@/stores/modules/favorite";
import { convertToTrackModel, isMobile } from "@/utils";
import { Delete, Edit, Lock, More, Plus, Search, Unlock, VideoPlay } from "@element-plus/icons-vue";
import { ElMessage, ElMessageBox, ElNotification, UploadProps } from "element-plus";
import "emoji-picker-element";
import { deletePlaylist } from "@/api/system";
import router from "@/routers";

// ================================ 歌单添加歌曲 ================================

//当前页 默认第一页
const currentPage = ref(1)
// 每页显示多少条 默认15条
const pageSize = ref(15)
// 查询参数表单
const queryParams = reactive({
  //歌曲名称
  songName: null,
  //歌手名称
  artistName: null,
  //专辑名称
  album: null
})

//定义一个统一配置 让 分页组件绑定这个配置 reactive针对复杂对象响应式
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: 0,
  pageSizes: [15, 30, 45],
})

// 歌曲列表数据
const searchSongs = ref([])

const getAllSongData = async () => {
  if (!queryParams.songName && !queryParams.album) {
    ElNotification.error('请输入歌曲名称或专辑名')
    return
  }
  const result = await getAllSongs({
    // 当前页
    pageNum: currentPage.value,
    // 每页多少条
    pageSize: pageSize.value,
    // 歌曲名称
    songName: queryParams.songName || null,
    // 歌手名称
    artistName: queryParams.artistName || null,
    // 专辑名称
    album: queryParams.album || null
  })

  if (result.code === 0 && result.data) {
    // 填充搜索候选的数据
    searchSongs.value = result.data.items
    // 告知分页组件 总数 让分页组件计算页码和页数
    pageConfig.total = result.data.total || 0
  }
}

// 添加歌曲到歌单
const handleAddSong2Playlist = async (song: Song) => {
  // 发送请求添加歌曲到歌单
  const result = await addSong2Playlist(song.songId, playlistDetail.value.playlistId)
  // 判断是否成功
  if (result.code === 0) {
    ElMessage.success('添加成功')
    getDetail(Number(playlistDetail.value.playlistId))
  } else {
    ElMessage.error(result.message)
  }
}

//导入用户缓存
const userStore = UserStore()
// 获取用户名
const currentUsername = computed(() => userStore.userInfo.username || '')
//导入收藏Store
const favoriteStore = useFavoriteStore()
// 导入播放器Store
const audioStore = AudioStore()

//导入播放器 加载播放列表 播放
const { loadTrack, play } = useAudioPlayer()
// 导入路由对象
const route = useRoute()

// 歌单数据
const playlistDetail = ref()
// 歌曲列表
const songs = ref<SongDetail[]>([])

//默认激活页签
const activeName = ref('歌曲列表')

//排序规则激活标识 默认规则最热排序
const isActive = ref('hot')



// =======================================评论功能相关方法与属性 =========================================

// 评论内容model
const commentContent = ref('')

//评论输入框引用
const inputRef = ref('')

// 发布评论
const handleAddComment = async () => {
  // 1. 再次检验用户是否登录
  if (!userStore.isLoggedIn) {
    ElMessage.warning("请先登录")
    return
  }

  //2. 检验内容是否为空值
  if (!commentContent.value.trim()) {
    ElMessage.warning("请先输入评论内容")
    return
  }

  //3. 发布评论 需要知道发布的内容是对应那个歌单 
  // 歌单ID 评论内容
  const playlistId = playlistDetail.value.playlistId
  const result = await addPlaylistComment({
    playlistId,
    content: commentContent.value.trim()
  })

  if (result.code === 0) {
    ElMessage.success("发布评论成功")
    //重新获取一次评论内容 
    await getDetail(Number(playlistId))
    //清空评论内容模型
    commentContent.value = ''
  } else {
    ElMessage.error("发布评论失败")
  }


}

//删除评论
const handleDeleteComment = async (comment: PlaylistComment) => {
  if (!userStore.isLoggedIn) {
    ElMessage.warning("请先登录")
    return
  }

  ElMessageBox.confirm(
    '是否删除这条评论?',
    'Warning',
    {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning',
    }
  )
    .then(async () => {
      // 确认删除后执行的逻辑
      //调用删除接口 删除评论 严格来说互联网基本没有彻底删除 一般都是逻辑删除 软删除
      const result = await deleteComment(comment.commentId)

      if (result.code === 0) {
        ElMessage.success("删除成功")
      } else {
        ElMessage.error(result.message ?? "删除失败")
      }
      // 执行完毕操作刷新歌单
      await getDetail(playlistDetail.value.playlistId)
    })
    .catch(() => {
      // 取消后执行的逻辑
    })
}

//评论选择表情事件

const handleEmoji = (event: any) => {
  /**
       * {
       emoji: {
      annotation: 'thumbs up',
      group: 1,
      order: 280,
      shortcodes: ['thumbsup', '+1', 'yes'],
      tags: ['+1', 'hand', 'thumb', 'up'],
      unicode: '👍️',
      version: 0.6,
      skins: [
          { tone: 1, unicode: '👍🏻', version: 1 },
          { tone: 2, unicode: '👍🏼', version: 1 },
          { tone: 3, unicode: '👍🏽', version: 1 },
          { tone: 4, unicode: '👍🏾', version: 1 },
          { tone: 5, unicode: '👍🏿', version: 1 }
      ]
      },
      skinTone: 4,
      unicode: '👍🏾'
      }
   */
  // 打印选择的表情
  console.log(event.detail.unicode)
  //1. 尾部追加表情
  // commentContent.value += event.detail.unicode
  //2. 光标处追加表情
  // 第二种方式比较麻烦 需要拿到输入框的ref 计算对应光标位置
  const input = inputRef.value?.$el.querySelector('textarea')
  console.log(input)
  // 如果这个元素为空 返回
  if (!input) return

  // 2.计算光标位置 selectionStart 选取文本的起始位置  selectionEnd 选取文本的结束位置
  // 123456 ==> 123 selectionStart =0  selectionEnd=2
  // 123456 ==> selectionStart =2  selectionEnd=2
  const start = input.selectionStart
  const end = input.selectionEnd
  // 3. 内容拼接
  const tempComment = commentContent.value
  //4. 截取评论内容的前半部分 + 表情 + 评论内容的后半部分
  commentContent.value = tempComment.substring(0, start) + event.detail.unicode + tempComment.substring(end)
  console.log('最后内容' + commentContent.value)

  //5.重置光标
  nextTick(() => {
    //5.1 重新聚焦
    input.focus()
    //5.2 重置光标到文本最后
    const len = start + event.detail.unicode.length
    input.setSelectionRange(len, len)

  })
  // commentContent.value.
}

//点赞与取消点赞
const handlLike = async (comment: PlaylistComment) => {
  //1. 判断用户是否登录
  if (!userStore.isLoggedIn) {
    ElMessage.warning("请先登录")
    return
  }

  //2. 点赞/取消赞
  // 2.1 判断当前评论是否已经是点赞状态 是 取消点赞 不是 点赞    
  const result = comment.liked ? await cancelLikeComment(comment.commentId) : await likeComment(comment.commentId)
  if (result.code === 0) {
    ElMessage.success("操作成功")
    //重新查询评论列表更新点赞数量
    await getDetail(Number(playlistDetail.value.playlistId))
    return
  } else {
    ElMessage.error('操作失败')
  }

}

// 获取歌单信息
const getDetail = async (id: number) => {
  const result = await getPlaylistDetail(id)
  if (result.code === 0) {
    // 歌单详情 携带 评论列表 以及 歌单附属歌曲列表
    console.log(result.data)
    
    playlistDetail.value = result.data as PlaylistDetail
    songs.value = playlistDetail.value.songs
    isPrivate.value = playlistDetail.value.isPrivate
  } else {
    ElMessage.error("获取歌单详情失败")
  }
}

// 监听函数 watch 动态监听的 只要有参数变化 就会监听变化过程
/**
 * source: WatchSource<unknown>,  数据源 观察源
 * cb: WatchCallback<unknown, unknown>, 监听回调函数 只要数据源变化 会将数据源传递给回调函数 
 * options?: WatchOptions<false>   监听选项
 */
watch(
  () => route.params.id,
  async (id: string) => {
    // console.log("我是id",id)
    // 获取歌单详情信息
    if (id) {
      // 手动激活歌曲列表页签
      activeName.value = '歌曲列表'
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
// 切换页签事件 name 页签名
const handleSwitchTab = async (name: any) => {
  //当前页签名称
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

//播放全部功能
const handlePlayAll = async () => {
  // 1. 获取当前歌单的歌曲列表 
  const songs = playlistDetail.value.songs
  //判断歌曲列表是否有歌曲 没有歌曲返回
  if (songs?.length === 0 || !songs) return

  //2. 解析歌曲列表为 播放列表 songs ==> trackList trackModel[]
  const trackList = songs.map((song) => convertToTrackModel(song))
    .filter((track) => track !== null)
  //3. 将歌曲列表 放入播放列表 头部 并且从第一首歌曲播放
  audioStore.setAudioStore('trackList', trackList)
  audioStore.setAudioStore('currentSongIndex', 0)
  // 加载播放列表
  await loadTrack()
  //播放音乐
  play()
}

// ==========================================编辑歌单相关功能======================================

const playlistForm = ref({
  //歌单ID
  playlistId: '',
  //歌单标题
  title: '',
  //歌单简介
  introduction: ''
})

// 歌单对话框控制变量
const showEditDialog = ref(false)

// 打开歌单编辑对话框
const openEditDialog = () => {

  //1. 回显数据
  playlistForm.value.playlistId = playlistDetail.value.playlistId
  playlistForm.value.title = playlistDetail.value.title
  playlistForm.value.introduction = playlistDetail.value.introduction
  //2.打开对话框
  showEditDialog.value = true
}

// 编辑歌单方法
const handleEditPlaylist = async () => {
  const result = await updatePlaylist(playlistForm.value)
  //更新歌单信息成功
  if (result.code === 0) {
    //关闭编辑对话框
    showEditDialog.value = false
    ElMessage.success("保存成功")
    //刷新歌单信息
    getDetail(Number(playlistDetail.value.playlistId))
  } else {
    ElMessage.error(result.message)
  }

  //最后一步清空编辑表单 
  playlistForm.value.playlistId = null
  playlistForm.value.title = null
  playlistForm.value.introduction = null
}

// 图片上传之前函数
const beforeAvatarUpload: UploadProps['beforeUpload'] = (rawFile) => {
  if (rawFile.type !== 'image/jpeg') {
    ElMessage.error('Avatar picture must be JPG format!')
    return false
  } else if (rawFile.size / 1024 / 1024 > 2) {
    ElMessage.error('Avatar picture size can not exceed 2MB!')
    return false
  }
  return true
}

//图片上传方法 options 包含图片本身 二进制文件
const handleAvatarUpload = async (options: any) => {
  //声明一个表单
  const form = new FormData()
  //表单添加图片
  form.append('cover', options.file)
  //获取后台接口地址 之前发送
  // json格式数据 或者
  // 文本类型数据 
  // 二进制数据类型
  const result = await updatePlaylistAvatar(playlistDetail.value.playlistId, form)
  //头像上传成功
  if (result.code === 0) {
    // 回显头像到上传组件中 result.data 
    // 1. 系统发回的头像的在线访问地址
    // 2. 同时系统也同步更新歌单的封面数据
    playlistDetail.value.coverUrl = result.data
  }

}

// 删除歌单
const handleDeletePlaylist = async () => {
  if (!playlistDetail.value) return;

  ElMessageBox.confirm(
    '确定要删除这个歌单吗？此操作不可撤销！',
    '警告',
    {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'error',
    }
  )
    .then(async () => {
      const result = await deletePlaylist(playlistDetail.value.playlistId);
      if (result.code === 0) {
        ElMessage.success('歌单删除成功');
        // 删除后刷新收藏列表
        favoriteStore.getFavoritePlaylists()
        // 删除成功后跳转到歌单列表页面
        router.push('/playlist');
      } else {
        ElMessage.error(result.message || '删除失败');
      }
    })

    .catch(() => {
      // 用户取消删除
      ElMessage.info('已取消删除');
    });
}

// 删除歌曲
// 移除歌曲时重新获取歌单详情
const handleSongRemoved = async (songId) => {
  // 调用移除歌曲的 API 或逻辑
  await removeSongFromPlaylist(playlistDetail.value.playlistId, songId)

  // 重新获取歌单详情，刷新页面
  await getDetail(Number(route.params.id))

  ElMessage.success('歌曲已移除')
}


// 设为私人
const isPrivate = ref(0)
// 切换方法
const togglePrivacy = async () => {
  if (!playlistDetail.value) return
  const updateData = {
    playlistId: playlistDetail.value.playlistId,
    isPrivate: isPrivate.value ? 0 : 1
  }
  const result = await updatePlaylist(updateData)

  if (result.code === 0) {
    console.log("设成啥了", isPrivate.value)
    ElMessage.success(isPrivate.value ? '设为私人' : '设为公开')
    await getDetail(Number(playlistDetail.value.playlistId))
  } else {
    ElMessage.error(result.message || '切换失败')
  }
}

// 组件创建生命周期函数 初始化数据 获取数据等等
onMounted(async () => {

})

// 组件卸载之前生命周期
onBeforeUnmount(() => {

})

// 用于评论列表排序
/**
 *    [{
    "commentId": 103,
    "username": "user_119",
    "userAvatar": null,
    "content": "这是一个随机歌单评论 359",
    "createTime": "2025-01-26",
    "likeCount": 45,
    "liked": null
} ]
 * @param type 
 */
const handleSort = (type: string) => {
  // 取出评论 作为临时变量排序用
  const tempComments = playlistDetail?.value.comments as PlaylistComment[]
  if (type === 'hot') {

    isActive.value = 'hot'
    // 最热排序 根据点赞数排序 数组  sort(比较器)
    playlistDetail.value.comments = tempComments.sort((a, b) => {
      return b.likeCount - a.likeCount
    })
  } else {
    isActive.value = 'new'
    //最新排序 根据评论时间排序 2025-01-26 ==> 时间毫秒值 数值型 
    //比较器返回值 > 0 b 比a大  =0 两个数相等 < 0 b比a小
    playlistDetail.value.comments = tempComments.sort((a, b) => {
      return new Date(b.createTime).getTime() - new Date(a.createTime).getTime()
    })
  }

}
//调用登录组件
const showLoginDialog = () => {
  //事件总线 调用 登录事件
  emitter.emit('show-login-dialog', { show: true })
}
</script>


<template>

  <div class="flex flex-col gap-y-4 h-screen  px-4 mx-1  md:mx-4 mt-4 p-4 ">

    <!-- 歌曲信息栏  -->
    <div class=" flex flex-col  md:flex-row w-full">
      <!-- 左边是 歌单封面 -->
      <el-image :src="playlistDetail?.coverUrl" class="w-full h-full md:w-60 md:h-60 rounded-lg object-cover shadow-lg">
        <template #placeholder>
          <el-image :src="defaultCoverImg"></el-image>
        </template>
      </el-image>

      <!-- 右边是歌单的信息 歌单名称 歌单的简介 歌单的创建人 与 歌单数量 -->
      <div class="flex flex-col  justify-between md:mx-4 mt-2">
        <!-- 歌单信息 列布局 -->
        <div class="flex flex-col gap-y-4">
          <!-- 歌单名称 -->
          <h1 class=" text-3xl font-bold  line-clamp-2">{{ playlistDetail?.title }}</h1>

          <!-- 歌单的简介 -->

          <p class=" text-muted-foreground ">{{ playlistDetail?.introduction }}</p>

          <!-- 歌单的创建人 以及 歌曲数量 行布局 -->

          <div class="flex flex-row gap-x-2 items-center text-muted-foreground">
            <!-- 行布局左侧歌单创建人头像 -->
            <el-image :src="defaultCoverImg" class=" w-12 h-12 rounded-full object-cover">
              <template #placeholder>
                <el-image :src="defaultCoverImg"></el-image>
              </template>
            </el-image>

            <!-- 歌单创建人名 -->
            <span v-if="playlistDetail?.createBy===userStore.userInfo.userId">{{ userStore.userInfo.username }}</span>
            <span v-else> Seecen Music</span>

            <!-- 歌单的数量  xx 首歌曲-->
            <span>{{ playlistDetail?.songs.length }} 首歌曲</span>
            <el-icon v-if="isPrivate" size="16" class="ml-2">
              <lock />
            </el-icon>

          </div>

        </div>

        <!-- 歌单信息功能栏行布局 -->

        <div class="flex flex-row gap-x-2 items-center">
          <!-- 左侧是 播放全部按钮 带图标  items-center y轴居中 justify-center x轴居中-->
          <button @click="handlePlayAll"
            class=" bg-blue-500 text-white p-3 rounded-lg inline-flex items-center justify-center gap-x-2  w-48 ">
            <!--VideoPlay图标 -->
            <el-icon size="30">
              <VideoPlay />
            </el-icon>
            播放全部
          </button>
          <!-- 右侧 喜欢按钮 也是图标 -->
          <button @click="toggleLike"
            class=" bg-gray-200 p-3 rounded-lg inline-flex items-center justify-center gap-x-2  w-16 ">
            <!-- 喜欢图标 -->
            <icon-ic:round-favorite v-if="playlistDetail?.likeStatus === 1" class="  text-2xl text-red-500 " />
            <icon-ic:round-favorite-border v-else class="  text-2xl " />

          </button>
          <!-- 右侧的功能栏 权限校验 歌单的创建人ID与当前登录用户ID是否一致-->
          <el-dropdown placement="bottom-start" v-if="playlistDetail?.createBy === userStore.userInfo.userId">
            <el-button class=" text-2xl h-14" size="large" :icon="More" />
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item :icon="Edit" @click="openEditDialog">编辑详情</el-dropdown-item>
                <el-dropdown-item :icon="Delete" @click="handleDeletePlaylist">删除歌单</el-dropdown-item>
                <el-dropdown-item v-if="isPrivate === 1" :icon="isPrivate ? Unlock : Lock" @click="togglePrivacy">

                  {{ "设为公开" }} <!-- 动态切换按钮文字 -->
                </el-dropdown-item>

                <el-dropdown-item v-else :icon="isPrivate ? Unlock : Lock" @click="togglePrivacy">

                  {{ "设为私有" }} <!-- 动态切换按钮文字 -->
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>


      </div>




    </div>


    <!-- 页签 歌曲 和 评论 -->

    <!-- 页签 或者 导航栏  flex-1 让元素占整个父容器 全部剩余空间 -->
    <div :class="[songs?.length < 10 ? 'flex-1' : '', 'flex']">
      <el-tabs v-model="activeName" :type="isMobile() ? '' : 'border-card'" class="overflow-auto w-full "
        @tab-click="handleSwitchTab">
        <!-- 歌曲列表  -->
        <el-tab-pane name="歌曲列表" label="歌曲列表">
          <!-- PC端显示的曲库组件 -->
          <Table v-if="!isMobile()" :playlistId="playlistDetail?.playlistId" :data="songs" @song-removed="handleSongRemoved">
            

          </Table>
          <!-- 移动端的曲库组件 -->
          <MobileList v-else :data="songs" :playlistId="playlistDetail?.playlistId" ></MobileList>
        </el-tab-pane>
        <!-- 歌单评论 -->
        <el-tab-pane name="歌单评论" label="歌单评论">
          <!-- 评论字段 comments 在查询歌单信息时候 携带过来了 数组 -->
          <!-- 评论功能 -->
          <!-- 评论列表 评论 最新 (创建时间倒排)与 最热(点赞数倒排)两个排序规则 -->
          <div class="flex flex-col mt-4">
            <!-- 评论顶部排序功能栏 行布局 -->
            <div class="flex flex-row items-center mb-2 gap-x-4">
              <!-- 显示评论总数  -->
              <h3 class="font-bold ">评论总数: {{ playlistDetail?.comments.length ?? 0 }}</h3>
              <!-- 评论排序规则 -->
              <button @click="handleSort('hot')" :class="[isActive === 'hot' ? 'text-black' : 'text-gray-500']"
                class="flex  hover:text-blue-400 items-center justify-center ">最热</button>
              <span> | </span>
              <button @click="handleSort('new')" :class="[isActive === 'new' ? 'text-black' : 'text-gray-500']"
                class="flex  hover:text-blue-400 items-center justify-center">最新</button>
            </div>


            <!-- 评论功能 是需要已经登录才可以评论 没有登录需提示用户登录 -->

            <div class="flex flex-row gap-x-3 mb-3">
              <!-- 当前用户信息头像 -->
              <el-avatar :src="userStore.userInfo.avatarUrl || defaultAvatar"></el-avatar>

              <!-- 列布局 输入框以及 发布按钮 已经登录 才显示输入框-->
              <div v-if="userStore.isLoggedIn" class="flex flex-1 flex-col gap-y-3 ">
                <!-- 输入框 -->
                <el-input ref="inputRef" v-model="commentContent" maxlength="200" rows="3" show-word-limit
                  placeholder="勇敢的少年啊快去创造热评~" type="textarea" />

                <!-- 评论功能栏 两端对齐 -->
                <div class="flex flex-row justify-between ">
                  <!-- 表情的容器 弹出层触发方式是点击式 -->
                  <el-popover width="348" placement="bottom" trigger="click">
                    <template #reference>
                      <!-- 图标 -->
                      <icon-mdi:emoji-outline />
                    </template>

                    <!-- 表情组件 -->
                    <emoji-picker @emoji-click="handleEmoji" class=" flex w-80 "></emoji-picker>

                  </el-popover>



                  <!-- 发布按钮 无内容时候 置灰 :disabled=""  -->
                  <el-button @click="handleAddComment" :disabled="!commentContent.trim()" class=" w-20 bg-blue-300 "
                    type="primary">发布</el-button>
                </div>

              </div>
              <!-- 未登录的情况 -->
              <div class="flex flex-1 gap-y-3 bg-gray-200
                             justify-center items-center rounded-lg h-14 text-gray-500" v-else>
                <span>请先</span>
                <el-button @click="showLoginDialog" class=" bg-blue-500" type="primary" size="small">登录</el-button>
                <span>后发布评论 (・ω・)</span>
              </div>
            </div>
            <div v-for="comment in playlistDetail?.comments" :key="comment.commentId">
              <!-- 列表渲染 -->
              <div class="flex  gap-3 ">

                <!-- 行布局 头像在左边 个人信息以及评论在右边 -->
                <div>
                  <el-image class=" h-10 w-10 rounded-full object-cover"
                    :src="comment.userAvatar || defaultAvatar"></el-image>
                </div>
                <!-- 评论信息部分 -->
                <div class="flex flex-1 flex-col gap-y-2 ">
                  <!-- 评论人 -->
                  <span class=" text-blue-500">{{ comment.username }}</span>
                  <!-- 评论的内容 -->
                  <p>{{ comment.content }}</p>
                  <!-- 评论时间与点赞数 -->
                  <div class=" flex flex-row gap-x-2 ">
                    <span class=" text-gray-400">{{ comment.createTime }}</span>
                    <!-- 点赞数 图标 + 点赞总数 如果是自己的评论显示删除功能
                                          如果已经点过赞了  修改一下颜色 让用户知道点过赞 再点就是取消点赞 -->
                    <button @click="handlLike(comment)"
                      class="flex gap-x-1.5 hover:text-blue-400 items-center justify-center ">
                      <!-- 点赞图标 -->
                      <icon-material-symbols:thumb-up :class="[comment.liked ? 'text-blue-400' : 'text-gray-400']" />
                      <!-- 点赞总数 -->
                      <span class="text-gray-400">{{ comment.likeCount }}</span>
                    </button>

                    <!-- 删除评论功能 -->
                    <button class="flex items-center justify-center text-gray-400"
                      v-if="comment.username === currentUsername" @click="handleDeleteComment(comment)">
                      <!-- 删除图标 -->
                      <icon-material-symbols:delete-outline />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
    <!-- 歌曲搜索栏 列布局 -->
    <div v-if="songs?.length < 10 && playlistDetail?.createBy === userStore.userInfo.userId"
      class=" flex flex-col gap-4 pb-16">
      <!-- 分割线 -->
      <!-- <el-divider /> -->

      <!-- 标题栏 -->
      <h2 class="text-2xl font-semibold">为你的歌单添加一些歌曲吧</h2>
      <!-- 歌曲搜索栏 -->
      <div class="flex flex-row w-full ">
        <el-input @change="getAllSongData" v-model="queryParams.songName" size="large" :prefix-icon="Search"
          class="w-72" placeholder="请输入歌曲名称"></el-input>
        <el-input @change="getAllSongData" v-model="queryParams.album" size="large" :prefix-icon="Search"
          class="w-72 ml-4" placeholder="请输入专辑名称"></el-input>

      </div>

      <!-- 歌曲候选列表 -->
      <div class="flex flex-col w-full h-full">
        <!-- 歌曲候选 -->
        <div class="flex flex-row justify-between items-center gap-2" v-for="(item, index) in searchSongs" :key="index">

          <div class="flex items-center justify-center">
            <!-- 专辑封面 -->
            <el-image class="rounded-2xl w-16 h-16" :src="item.coverUrl">
              <!-- 占位内容，加载比较慢的情况下 默认先贴一张静态图显示 -->
              <template #placeholder>
                <el-image :src="defaultCoverImg" />
              </template>
            </el-image>

            <!-- 歌曲信息 -->
            <!-- text-left 文本左对齐 左外边距4px  -->
            <div class="text-left ml-4">
              <!-- 歌曲名称 -->
              <h3 class="font-medium">{{ item.songName }}</h3>
              <!-- 歌曲作者 text-muted-foreground 次要文字颜色 -->
              <p class="text-sm text-muted-foreground line-clamp-1">
                {{ item.artisName }}
              </p>
            </div>

          </div>

          <!-- 添加歌单 按钮 -->
          <div class="text-right mr-5">
            <el-button @click="handleAddSong2Playlist(item)" round plain>添加</el-button>
          </div>

        </div>

        <!-- 专辑候选 这里可以复用 歌单详细页面 做专辑详细 -->

      </div>

    </div>

    <!-- 编辑歌单详情对话框 -->
    <el-dialog v-model="showEditDialog" title="编辑歌单" width="800">
      <!-- 对话框内容部分 行布局 -->
      <div class="flex flex-row p-3 gap-x-3">
        <!-- 左侧歌单封面 -->
        <el-upload class="avatar-uploader" :show-file-list="false" :http-request="handleAvatarUpload"
          :before-upload="beforeAvatarUpload">
          <!-- 左边是 歌单封面 -->
          <el-image v-if="playlistDetail?.coverUrl" :src="playlistDetail?.coverUrl"
            class="w-full h-full md:w-60 md:h-60 rounded-lg object-cover shadow-lg">
            <template #placeholder>
              <el-image :src="defaultCoverImg"></el-image>
            </template>
          </el-image>
          <el-icon class="avatar-uploader-icon" v-else>
            <Plus />
          </el-icon>
        </el-upload>
        <!-- 右侧歌单的标题与简介 列布局 -->

        <div class="flex flex-1 flex-col gap-y-3">
          <el-input v-model="playlistForm.title" placeholder="请输入歌单名称" />

          <el-input v-model="playlistForm.introduction" type="textarea" maxlength="200" rows="6" show-word-limit
            placeholder="添加简介(可选)" />
        </div>
      </div>
      <!-- 对话框底部部分 -->
      <template #footer>
        <div class="dialog-footer gap-x-2">
          <el-button @click="showEditDialog = false">取消</el-button>
          <el-button type="primary" @click="handleEditPlaylist">
            保存歌单
          </el-button>
        </div>
      </template>
    </el-dialog>



  </div>

</template>

<style lang="css">
.avatar-uploader .el-upload {
  border: 1px dashed var(--el-border-color);
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: var(--el-transition-duration-fast);
}

.avatar-uploader .el-upload:hover {
  border-color: var(--el-color-primary);
}

.el-icon.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
}
</style>