<script setup lang="ts">
import Header from './components/header/index.vue'
import Aside from './components/aside/index.vue'
import Main from './components/main/index.vue'
import Footer from './components/footer/index.vue'
import Navigator from './components/mobile/navigator/index.vue'
import BG from './components/bg/index.vue'
import { AudioPlayer } from '@/hooks/useAudioPlayer'
import { isMobile } from '@/utils'

provide('audioPlayer', AudioPlayer())

let lastWidth = window.innerWidth
const handleResize = () => {
  const currentWidth = window.innerWidth
  if (currentWidth !== lastWidth) {
    location.reload() // 刷新页面
  }
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
})
</script>
<template>
  <!-- <BG /> -->
  <div class="absolute w-full flex flex-col h-full">
    <div
      class="w-full flex flex-col h-full overflow-hidden bg-themeBgColor backdrop-blur-lg"
    >
      <!--      页头-->
      <Header />

      <!--      手机顶部导航栏-->
      <Navigator v-if="isMobile()" />
      <!--      页面主体-->
      <div class="flex flex-1 overflow-hidden">
        <!--        侧边栏-->
        <Aside />
        <!--        页面内容-->
        <Main />
      </div>
      <Footer />
    </div>
  </div>
</template>
