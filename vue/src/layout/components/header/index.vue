<script setup lang="ts">
import { Icon } from '@iconify/vue'
import Avatar from './components/avatar.vue'
import { useDark, useToggle } from '@vueuse/core'
import { isMobile } from '@/utils'

const route = useRoute()
const router = useRouter()
const currentIcon = ref('material-symbols:wb-sunny-outline-rounded')
const theme = themeStore()

const searchText = ref('')

const isDark = useDark({
  selector: 'html',
  attribute: 'class',
  valueDark: 'dark',
  valueLight: 'light',
})
const toggleDark = useToggle(isDark)

const toggleMode = () => {
  theme.setDark(!isDark.value)
  toggleDark()
}

// 初始化时根据 store 设置图标
watch(
  () => theme.isDark,
  (newValue) => {
    currentIcon.value = newValue
      ? 'mdi:weather-night'
      : 'material-symbols:wb-sunny-outline-rounded'
  },
  { immediate: true }
)

// 赋值到搜索框
watch(
  () => route.query,
  (newValue) => {
    if (newValue.query) {
      searchText.value = newValue.query as string
    }
  },
  { immediate: true }
)
</script>
<template>
  <header class="px-4 py-2 border-b flex items-center justify-between w-full">
    <button class="flex items-center" @click="router.push('/')">
      <img
        :class="isMobile() ? 'w-8 h-8' : 'w-16 h-16'"
        alt="logo"
        class="w-16 h-16"
        src="\logo.svg"
      />
      <span :class="isMobile() ? 'text-xs' : 'text-xl'" class="ml-2 font-bold"
        >Seecen Music</span
      >
    </button>

    <!-- 搜索框 -->
    <div class="relative mx-4 flex-grow max-w-md">
      <Icon
        icon="mdi:magnify"
        class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-500 text-lg"
      />
      <input
        v-model="searchText"
        type="text"
        class="w-full h-12 pl-10 pr-4 py-2 text-sm rounded-lg focus:outline-none focus:ring-2 focus:ring-primary transition-all duration-300 search-bg"
        placeholder="搜索..."
        @keyup.enter="router.push('/library?query=' + searchText)"
      />
    </div>

    <!-- 右侧操作 -->
    <div class="flex items-center gap-3">
      <button @click="toggleMode">
        <Icon class="text-lg" :icon="currentIcon" />
      </button>
      <Avatar />
    </div>
  </header>
</template>

<style scoped>
.search-bg {
  background-color: #e3e3e3;
}
</style>
