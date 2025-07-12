<script lang="ts" setup>

// 歌词数组 当前歌词播放位置
const props = defineProps<{
  // 歌词数组
  lyrics: LyricLine[]
  // 歌曲播放位置
  currentIndex: number
}>()

/**
 * Spotify
 * 全部渲染歌词数组
 * 不隐藏歌词 overflow-auto 让歌词滑动
 * 使用watch 函数监听 currentIndex
 */
// const lyricsRef=ref<HTMLDivElement[]>([])

// watch(()=>props.currentIndex,(newIndex)=>{
//   const newLine = lyricsRef.value[newIndex]
//   if(newLine){
//     newLine.scrollIntoView({
//       behavior:'smooth',
//       block:'center'
//     })
//   }
// })

/**
 * 替换数组
 * 观察索引变化 有变化取出对应一部分歌词 进行渲染
 * 采用计算属性的方式 去计算需要获取的歌曲行
 * 
 */
const tmpLine = computed(() => {
  // 一次性取出四条 50 48
  const startIndex = Math.max(props.currentIndex, 0)
  const endIndex = Math.min(startIndex + 4, props.lyrics.length - 1)
  return props.lyrics.slice(startIndex, endIndex + 1).map((line, index) => ({
    ...line,
    absIndex: startIndex + index
  }))
})

</script>


<template>
  <!-- 歌词容器 -->
  <div class="flex flex-col overflow-hidden min-h-36 max-h-40 justify-center
   items-center text-center py-2">
    <!-- 循环所有歌词 显示当前播放的歌词 -->
    <div v-for="(line,index) in tmpLine" :key="line.absIndex" :class="['transition-all duration-300',
      line.absIndex === currentIndex ? 'text-blue-400 font-semibold' : 'text-gray-400',
      line.translation ? 'tex-base' : 'text-2xl']">
      <!-- 歌词 -->
      <p>{{ line.text }}</p>
      <!-- 翻译显示 -->
      <p v-if="line.translation">{{ line.translation }}</p>

    </div>

  </div>

</template>


<style lang="css"></style>