<script setup lang="ts">
import Left from './components/left.vue'
import Center from './components/center.vue'
import Right from './components/right.vue'
import { isMobile } from '@/utils'
import { useAudioPlayer } from '@/hooks/useAudioPlayer.ts'

const { currentTime, duration } = useAudioPlayer()
</script>
<template>
  <footer
    v-if="!isMobile()"
    class="border-t flex items-center justify-between shadow-2xl shadow-black"
  >
    <!-- 左边：歌曲封面和歌曲名称 -->
    <Left />
    <!-- 中间：控制区 -->
    <Center />
    <!-- 右边：历史播放和音量 -->
    <Right />
  </footer>

  <footer
    v-else-if="isMobile()"
    class="w-full border-t flex items-center justify-between shadow-2xl shadow-black"
  >
    <div class="w-full flex-row items-center">
      <div class="flex items-center justify-between shadow-2xl shadow-black">
        <!-- 左边：歌曲封面和歌曲名称 -->
        <Left class="w-1/3" />
        <!-- 中间：控制区 -->
        <Center class="w-1/3" />
        <!-- 右边：历史播放和音量 -->
        <Right class="w-1/3" />
      </div>

      <el-slider
        v-model="currentTime"
        :show-tooltip="false"
        :max="duration"
        class="h-1 my-0"
        size="small"
      />
    </div>
  </footer>
</template>
