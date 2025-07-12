import { trackModel } from '@/stores/interface'
import { ElNotification } from 'element-plus'
import { PlayMode } from './interface'
import { urlV1 } from '@/api'
import { addPlayLog } from '@/api/system.ts'
import { UserStore } from '@/stores/modules/user.ts'
import { parseLRC } from '@/utils/parsedLyrics'

interface AudioPlayer {
  isPlaying: Ref<boolean>
  currentTrack: ComputedRef<trackModel>
  currentTime: Ref<number>
  duration: Ref<number>
  volume: Ref<number>
  currentLyricIndex: Ref<number>
  audioElement: Ref<HTMLAudioElement | null>
  play: () => void
  pause: () => void
  nextTrack: () => void
  prevTrack: () => void
  seek: (time: number) => void
  togglePlayPause: () => void
  setVolume: (volume: number) => void
  setPlayMode: (mode: PlayMode) => void
  loadTrack: () => Promise<void>
}

export const AudioPlayer = () => {
  const audioStore = AudioStore()
  const userStore = UserStore()
  const audioElement = ref<HTMLAudioElement | null>(null)
  const isPlaying = ref(false)
  const volume = ref()
  const playMode = ref<PlayMode>('order') // 默认为顺序播放

  // 当前播放的歌曲
  const currentTrack = computed<trackModel>(
    () => audioStore.trackList[audioStore.currentSongIndex] || []
  )
  const currentTime = ref(0)
  const duration = ref(0)

  // 用于追踪当前歌词索引
  const currentLyricIndex = ref(0)

  // 更新当前歌曲歌词索引
  const updateCurrentLyricIndex = (newTime: number = 0) => {
    if (!currentTrack.value.lyrics) return

    // 找到当前时间对应的歌词行
    const lyrics = currentTrack.value.lyrics
    const targetIndex = lyrics.findIndex(
      // 以秒为单位 计算当前进度事件是否超过 歌曲播放进度时间
      (line: { time: number }) => line.time > newTime
    )
    // 记录当前歌词索引 方便其他组件知道歌词现在在哪一行
    currentLyricIndex.value =
      targetIndex === -1 ? lyrics.length - 1 : targetIndex - 1
  }

  // 播放音乐
  const play = () => {
    if (audioElement.value) {
      audioElement.value.play()
      isPlaying.value = true

      //断点续听
      // const lastPlayIndex = audioStore.getAudioStore('lastPlayIndex')
      // const lastPlayTime = audioStore.getAudioStore('lastPlayTime')
      const currentSongIndex = audioStore.getAudioStore('currentSongIndex')
      // if (lastPlayTime !== 0 && lastPlayIndex === currentSongIndex) {
      //   seek(lastPlayTime)
      // }

      if (userStore.isLoggedIn) {
        const music = audioStore.getAudioStore('trackList')[
          currentSongIndex
        ] as trackModel
        const songId = music.id

        //埋点日志
        addPlayLog({
          songId: songId,
          userId: userStore.userInfo.userId,
          source: '首页',
        })
      }
    }
  }
  // 跳转到指定时间
  const seek = (time: number) => {
    if (audioElement.value) {
      audioElement.value.currentTime = time
      currentTime.value = time
    }
  }
  // 暂停音乐
  const pause = () => {
    if (audioElement.value) {
      audioElement.value.pause()
      isPlaying.value = false
    }
  }

  // 播放下一首
  const nextTrack = async () => {
    switch (playMode.value) {
      case 'loop':
        if (audioStore.currentSongIndex < audioStore.trackList.length - 1) {
          audioStore.currentSongIndex++
        } else {
          audioStore.currentSongIndex = 0 // 从头开始
        }
        break
      case 'shuffle':
        audioStore.currentSongIndex = Math.floor(
          Math.random() * audioStore.trackList.length
        )
        break
      case 'single':
        audioElement.value!.currentTime = 0
        break
      case 'order':
      default:
        if (audioStore.currentSongIndex < audioStore.trackList.length - 1) {
          audioStore.currentSongIndex++
        } else {
          audioStore.currentSongIndex = 0 // 从头开始
        }
        break
    }
    await loadTrack()
    play()
  }

  // 播放上一首
  const prevTrack = async () => {
    switch (playMode.value) {
      case 'loop':
        if (audioStore.currentSongIndex > 0) {
          audioStore.currentSongIndex--
        } else {
          audioStore.currentSongIndex = audioStore.trackList.length - 1 // 从尾开始
        }
        break
      case 'shuffle':
        audioStore.currentSongIndex = Math.floor(
          Math.random() * audioStore.trackList.length
        )
        break
      case 'single':
        audioElement.value!.currentTime = 0
        break
      case 'order':
      default:
        if (audioStore.currentSongIndex > 0) {
          audioStore.currentSongIndex--
        } else {
          audioStore.currentSongIndex = audioStore.trackList.length - 1 // 从尾开始
        }
        break
    }
    await loadTrack()
    play()
  }

  // 加载当前歌曲
  const loadTrack = async () => {
    // 检查歌曲 URL
    await checkUrl()
    // 歌词是否存在
    checkLyrics()

    if (audioElement.value) {
      audioElement.value.src = currentTrack.value.url
      audioElement.value.load()
    }
  }

  // 检查歌曲 URL
  const checkUrl = async () => {
    // 查看歌曲 URL 是否存在
    if (!currentTrack.value.url) {
      // 如果 currentTrack 的 url 不存在，则获取 URL
      const response = await urlV1(currentTrack.value.id)
      const url = response.data[0]?.url // 获取第一个 URL

      if (!url) return
      // 更新 trackList 中的对应歌曲的 url
      const trackIndex = audioStore.trackList.findIndex(
        (track: { id: any }) => track.id === currentTrack.value.id
      )
      if (trackIndex !== -1) {
        audioStore.trackList[trackIndex].url = url // 更新 URL
      }
    }
    return Promise.resolve()
  }

  // 解析歌词数据
  const checkLyrics = async () => {
    // 查看歌词是否存在
    if (!currentTrack?.value.lyricUrl) {
      return
    }
    // 存在 则再发送请求解析歌词文件
    try {
      const result = await fetch(currentTrack.value.lyricUrl)
      console.log("歌词地址", result);
      
      // 获取歌词失败
      if (!result.ok) {
        console.error("获取歌词失败", currentTrack.value.lyricUrl)
        return
      }
      // 获取歌词文件即将歌词文件解析为文本内容
      const lrcTexts = await result.text()
      console.log("歌词文件", lrcTexts)
      
      // 解析文本内容为歌词数组
      const lrcLines = parseLRC(lrcTexts)
      // 将解析后的歌词数组 填充给当前播放的歌曲 歌词数组属性
      currentTrack.value.lyrics = lrcLines
      console.log("歌词", currentTrack.value.lyrics)
    } catch (e) {
      // 解析歌词失败情况 处理歌词解析不到的情况
      console.log("歌词解析失败", e);
      currentTrack.value.lyrics = []
    }
  }

  // 更新当前播放时间
  const updateTime = () => {
    if (audioElement.value) {
      currentTime.value = audioElement.value.currentTime
      //保存播放时间 下次继续播放
      audioStore.setAudioStore('lastPlayTime', currentTime.value)
    }
  }

  // 更新总时长
  const onLoadedMetadata = () => {
    if (audioElement.value) {
      duration.value = audioElement.value.duration
    }
  }

  // 切换播放/暂停状态
  const togglePlayPause = () => {
    if (isPlaying.value) {
      pause()
    } else {
      play()
    }
  }

  // 设置音量
  const setVolume = (newVolume: number) => {
    if (audioElement.value) {
      volume.value = newVolume
      audioStore.setAudioStore('volume', newVolume)
      audioElement.value.volume = newVolume / 100
    }
  }

  // 设置播放模式
  const setPlayMode = (mode: PlayMode) => {
    playMode.value = mode
    const modeText = {
      order: '顺序播放',
      shuffle: '随机播放',
      loop: '列表循环',
      single: '单曲循环',
    }
    ElNotification({
      title: '播放模式',
      message: `已切换为${modeText[mode]}`,
      type: 'success',
    })
  }

  //   // 更新currentLyricIndex
  watch(currentTime, (newTime) => {
    updateCurrentLyricIndex(newTime)
  })

  // 组件挂载时初始化音频元素
  onMounted(() => {
    audioElement.value = new Audio(currentTrack.value.url)
    volume.value = audioStore.volume || 50
    audioElement.value.volume = volume.value / 100
    // 歌词是否存在
    checkLyrics()
    // 添加事件监听器
    audioElement.value.addEventListener('timeupdate', updateTime)
    audioElement.value.addEventListener('ended', nextTrack)
    audioElement.value.addEventListener('loadedmetadata', onLoadedMetadata)
  })

  // 组件卸载时移除事件监听器
  onUnmounted(() => {
    if (audioElement.value) {
      audioElement.value.removeEventListener('timeupdate', updateTime)
      audioElement.value.removeEventListener('ended', nextTrack)
      audioElement.value.removeEventListener('loadedmetadata', onLoadedMetadata)
    }
  })

  const audioPlayer: AudioPlayer = {
    isPlaying,
    currentTrack,
    currentTime,
    duration,
    volume,
    currentLyricIndex,
    audioElement,
    play,
    pause,
    nextTrack,
    prevTrack,
    seek,
    togglePlayPause,
    setVolume,
    setPlayMode,
    loadTrack,
  }

  return audioPlayer
}

export const useAudioPlayer = (): AudioPlayer => {
  const audioPlayer = inject<AudioPlayer>('audioPlayer')
  if (!audioPlayer) {
    throw new Error('useAudioPlayer must be used within a provider')
  }
  return audioPlayer
}
