<script setup lang="ts">
import { Icon } from '@iconify/vue'
import router from '@/routers'

const activeTab = ref('recommend')

const tabItems = [
  {
    name: 'recommend',
    icon: 'ri:home-smile-2-line',
    text: '推荐',
    router: '/',
  },
  {
    name: 'library',
    icon: 'ri:music-2-line',
    text: '乐库',
    router: '/library',
  },
  {
    name: 'playlist',
    icon: 'ri:album-line',
    text: '歌单',
    router: '/playlist',
  },
  {
    name: 'liked',
    icon: 'ri:heart-line',
    text: '喜欢',
    router: '/like',
  },
]
</script>

<template>
  <div class="w-full">
    <!-- 顶部标签 -->
    <el-tabs
      v-model="activeTab"
      type="card"
      class="!border-none"
      tab-position="top"
      stretch
    >
      <el-tab-pane v-for="item in tabItems" :key="item.name" :name="item.name">
        <template #label>
          <span
            class="flex items-center justify-center gap-1"
            @click="router.replace(item.router)"
          >
            <el-icon>
              <Icon :icon="item.icon" />
            </el-icon>
            <span>{{ item.text }}</span>
          </span>
        </template>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<style scoped>
:deep(.el-tabs__header) {
  @apply border-b border-gray-200;
  margin: 0 !important;
}
</style>
