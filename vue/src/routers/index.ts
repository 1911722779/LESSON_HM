import {
  createRouter,
  createWebHistory,
  createWebHashHistory,
} from 'vue-router'

const mode = import.meta.env.VITE_ROUTER_MODE

// 路由模式
// 1. WebHistory 历史记录模式 基于浏览器自己的浏览记录 去导航页面
// 2. WebHashHistory 哈希记录模式 哈希模式基于对浏览器地址的哈希算法 去导航页面 一般为默认模式
const routerMode = {
  hash: () => createWebHashHistory(),
  history: () => createWebHistory(),
}

const router = createRouter({
  history: routerMode[mode](),
  strict: false,
  scrollBehavior: () => ({ left: 0, top: 0 }),
  // 路由表，定义项目中的页面和路径
  routes: [
    {
      path: '/',
      // 首页
      component: () => import('@/pages/index.vue'),
    },
    {
      path: '/library',
      // 曲库
      component: () => import('@/pages/library/index.vue'),
    },
    {
      path: '/artist',
      // 歌手
      component: () => import('@/pages/artist/index.vue'),
    },
        {
      path: '/playlist',
      // 歌单
      component: () => import('@/pages/playlist/index.vue'),
    },
  ],
})

export default router
