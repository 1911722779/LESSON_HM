<script setup lang="ts">
// ElementUI icon库
import { MapLocation, Search, User } from '@element-plus/icons-vue'
import { categories } from '@/utils/enum'
import defaultCoverImg from '@/assets/cover.png'

// 查询数据库中有哪些分类 歌手分类 地区分类


onMounted(async () => {})
</script>

<template>
  <!-- 
    flex 弹性布局
    flex-col 列布局
    flex-2 2列
    h-full 高度100%
    overflow-hidden 溢出隐藏 
  -->
  <div class="flex flex-row flex-1 h-full overflow-hidden">
    <!-- 左边一列是 歌手分类菜单栏 占一列 -->

    <div class="flex flex-col p-5 ml-3">
      <!-- 标题栏 -->
      <div class="flex flex-row items-center justify-between mb-4">
        <h2 class="text-lg font-semibold">歌手分类</h2>

        <!-- 重置图标 -->
        <button
          class="inline-flex items-center justify-between text-sm text-gray-500"
        >
          <icon-bx:reset class="mr-1 h-5 w-5" />
          重置
        </button>
      </div>

      <!-- 搜索栏 -->
      <div class="flex flex-row items-center justify-between mb-4">
        <!-- 复合型输入框 左边有一个icon 右边是输入框 -->
        <el-input
          size="large"
          placeholder="搜索歌手"
          :prefix-icon="Search"
        />
      </div>
      <div class="flex flex-col h-full">
        <!-- 菜单栏 -->
        <el-menu class="menu" default-active="1">
          <!-- 一级菜单 歌手类型 -->
          <!-- 二级菜单
              一级菜单 1
              二级菜单 1-1 1-2 1-3
              index="1-1" 
          -->
          <el-sub-menu v-for="(subMenu,index) in categories" :key="index" 
          :index="index">
            <template #title>
              <el-icon>
                <User v-if="index === 0" />
                <MapLocation v-else />
              </el-icon>
              <span>{{ subMenu.name }}</span>
            </template>
            <!-- 循环生成一级菜单 -->
            <el-menu-item v-for="category in subMenu.subCategories" :key="category.id" 
            :index=" index + '-' + category.id ">
            <!-- 二级菜单名称 -->
              <template #title>{{ category.label }}</template>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </div>
    </div>

    <!-- 右边一列是 歌手信息栏 -->

    <main class="flex-1 w-[85%] mx-auto p-5 ">
      <!-- 网格布局 歌手信息 -->
      <div class="grid grid-cols-4 gap-x-16 gap-y-8 w-full h-full">
        <!-- 每个歌手的信息 -->
        <div class="group relative rounded-full text-card-foreground shadow-md hover:shadow-xl" 
          v-for="item in 20 " :key="item">
          <el-image :src="defaultCoverImg">
            <!-- 占位内容 加载较慢时显示 -->
            <template #placeholder>
              <el-image :src="defaultCoverImg" />
            </template>
          </el-image>
          <!-- 写简单的歌手信息介绍 效果 -->


          <!-- 遮罩层 先把歌手的头像遮住
             group-hover:opacity-100 遮罩层透明度100%
          -->
          <div class="absolute inset-0 bg-black/50 opacity-0 
            transition-opacity duration-300
            group-hover:opacity-100 rounded-full
          ">
          <!-- 在遮罩层显示歌手信息 -->
          <div class="absolute bottom-0 left-5 right-0 px-4 py-3 text-white
            trasition-opacity duration-300 group:hover:opacity-100 z-10
            mb-4 ml-5 mt-10 
          ">
            <h2 class="text-x font-semibold">G.E.M.邓紫棋</h2>
            <p class="text-sm mb-2">歌手的别称</p>
          </div>

          </div>

        </div>

      </div>
      <!-- 分页组件 -->

    </main>

  </div>
</template>

<style lang="css" scoped>
/* 菜单栏高度拉满屏幕 */
.menu {
  height: 100vh;
}
:deep(.el-input__wrapper) {
  border-radius: 12px;
}
</style>