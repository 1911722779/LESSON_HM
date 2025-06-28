<script setup lang="ts">
// ElementUI icon库
import { MapLocation, Search, User } from '@element-plus/icons-vue'
import { categories, categoryTags } from '@/utils/enum'
import defaultCoverImg from '@/assets/cover.png'
import { Artist } from '@/api/interface'
import { getAllArtists } from '@/api/system'
import { onMounted, ref } from 'vue'
import { isMobile } from '@/utils'
import { get } from 'http'
import { tagEmits } from 'element-plus'

// 当前页
const currentPage = ref(1)
// 每页显示多少条
const pageSize = ref(20)
// 总数
const total = ref(0)

// 歌手搜索变量
const searchKeyword = ref('')

// 歌手列表数组
const artisList = ref([])

// 存储用户已选条件
const tags1 = ref([])
const tags2 = ref([])

const queryParams = ref({
  pageNum: currentPage.value,
  pageSize: pageSize.value,
  // 歌手名字参数
  artistName: '',
  // 歌手性别
  gender: '',
  // 歌手所在国家
  area: '',
})

// 查询数据库中有哪些歌手
const getArtistList = async () => {
  const result = await getAllArtists(queryParams.value)
  if (result.code === 0 && result.data) {
    // console.log(result.data)
    // 歌手数组
    artisList.value = result.data.items as Array<Artist>
    // 歌手总数的赋值
    pageConfig.total = result.data.total
  }
}

// 定义一个统一配置 让分页组件版内搞定这个配置
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: total.value,
  pageSizes: [20, 30, 40],
})

// 页码 与 当前页 变更事件
/**
 * currentPage: number, pageSize: number
 * @param currentPage
 * @param pageSize
 */
const handleChange = async (currentPage: number, pageSize: number) => {
  // 更新页码与当前页数据
  queryParams.value.pageNum = currentPage
  queryParams.value.pageSize = pageSize
  await getArtistList()
}

// 重置搜索事件
const handleReset = async () => {
  // 会有搜索条件 queryParams 需要重置参数
  queryParams.value = {
    pageNum: 1,
    pageSize: pageSize.value,
    // 歌手名字参数
    artistName: '',
    // 歌手性别
    gender: '',
    // 歌手所在国家
    area: '',
  }
  // 重置tag标签
  tags1.value = []
  tags2.value = []
  // 重新查询歌手信息列表
  await getArtistList()
}

// 搜索歌手名称事件
const handleSearch = async () => {
  // 会有搜索条件 queryParams 需要重置参数
  queryParams.value = {
    pageNum: 1,
    pageSize: pageSize.value,
    // 歌手名字参数
    artistName: searchKeyword.value,
    // 歌手性别
    gender: '',
    // 歌手所在国家
    area: '',
  }
  // 重新查询歌手信息列表
  await getArtistList()
}
// 搜索歌手类别事件
const handleSelect = async (category: string | number) => {
  // 已经拿到了用户选择的搜索条件 去categoryTags中找到对应的label
  // 如果查到了相同的值 需要添加到tag标签显示查询条件
  const tag = categoryTags.value.find((ca) => ca.value === category)

  // 会有搜索条件 queryParams 需要重置参数
  queryParams.value = {
    pageNum: 1,
    pageSize: pageSize.value,
    // 歌手名字参数
    artistName: searchKeyword.value,
    // 歌手性别
    gender: queryParams.value.gender,
    // 歌手所在国家
    area: queryParams.value.area,
  }

  // 如果是数值型 说明是性别搜索
  if (typeof category === "number") {
    queryParams.value.gender = category?.toString() || ''
    // 添加之前清空
    tags1.value = []
    // 添加到tags，显示查询条件
    if (!tags1.value.includes(tag)) {
      tags1.value.push(tag)
    }
  } else {
    // 国家搜索
    queryParams.value.area = category?.toString() || ''
    // 添加之前清空
    tags2.value = []
    // 添加到tags，显示查询条件
    if (!tags2.value.includes(tag)) {
      tags2.value.push(tag)
    }
  }

  // 重新查询歌手信息列表
  await getArtistList()
}

onMounted(async () => {
  await getArtistList()
})
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
          @click="handleReset"
          class="inline-flex items-center justify-between text-sm text-gray-500"
        >
          <icon-bx:reset class="mr-1 h-5 w-5" />
          重置
        </button>
      </div>

      <!-- 搜索栏 -->
      <div class="flex flex-row items-center justify-between mb-4">
        <!-- 复合型输入框 左边有一个icon 右边是输入框
          @keyup.enter="handleSearch" 按下回车键时触发 
        -->
        <el-input
          @keyup.enter="handleSearch"
          v-model="searchKeyword"
          size="large"
          placeholder="搜索歌手"
          :prefix-icon="Search"
        />
      </div>

      <!-- 菜单栏 -->
      <div class="flex flex-col">
        <!-- 标签栏 -->
        <el-row class="w-48 gap-x-1 gap-y-1 my-2">
          <el-tag
            class="w-18"
            v-for="tag in tags1"
            :key="tag.uid"
            type="primary"
          >
            {{ tag.label }}
          </el-tag>

                    <el-tag
            class="w-18"
            v-for="tag in tags2"
            :key="tag.uid"
            type="success"
          >
            {{ tag.label }}
          </el-tag>
        </el-row>

        <el-menu class="menu border-none" default-active="0--1">
          <!-- 一级菜单 歌手类型 -->
          <!-- 二级菜单
              一级菜单 1
              二级菜单 1-1 1-2 1-3
              index="1-1" 
          -->
          <el-sub-menu
            v-for="(subMenu, index) in categories"
            :key="index"
            :index="index.toString()"
          >
            <template #title>
              <el-icon>
                <User v-if="index === 0" />
                <MapLocation v-else />
              </el-icon>
              <span class="font-semibold">{{ subMenu.name }}</span>
            </template>
            <!-- 循环生成二级菜单 -->
            <el-menu-item
              @click="handleSelect(category.value)"
              v-for="category in subMenu.subCategories"
              :key="category.id"
              :index="index + '-' + category.id"
            >
              <!-- 二级菜单名称 -->
              <template #title>
                <span class="font-semibold">
                  {{ category.label }}
                </span>
              </template>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </div>
    </div>

    <!-- 右边一列是 歌手信息栏 -->

    <main
      class="flex flex-col justify-between flex-1 w-[85%] mx-auto p-5 overflow-auto"
    >
      <!-- 网格布局 歌手信息 -->
      <div class="grid grid-cols-5 gap-x-16 gap-y-8 w-full">
        <!-- 每个歌手的信息 -->
        <div
          class="group relative rounded-full text-card-foreground shadow-md hover:shadow-xl"
          v-for="item in artisList"
          :key="item.artistId"
        >
          <el-image
            lazy
            :src="item.avatar"
            class="w-full h-full rounded-full object-cover"
          >
            <!-- 占位内容 加载较慢时显示 -->
            <template #placeholder>
              <el-image :src="defaultCoverImg" />
            </template>
          </el-image>
          <!-- 写简单的歌手信息介绍 效果 -->

          <!-- 遮罩层 先把歌手的头像遮住
             group-hover:opacity-100 遮罩层透明度100%
          -->
          <div
            class="absolute inset-0 bg-black/50 opacity-0 transition-opacity duration-300 group-hover:opacity-100 rounded-full"
          >
            <!-- 在遮罩层显示歌手信息 -->
            <div
              class="absolute inset-0 flex flex-col items-center justify-center px-2 py-1 text-white opacity-0 transition-opacity duration-300 group-hover:opacity-100 z-10"
            >
              <!-- truncate：当文本超出容器宽度时自动省略，显示为 ...
                w-4/5：设置宽度为父容器的 80%（即五分之四） 
              -->
              <h2
                class="mb-1 text-xs md:text-sm lg:text-base font-semibold text-center truncate w-4/5"
              >
                {{ item.artistName }}
              </h2>
              <p
                class="text-xs md:text-sm lg:text-base text-center truncate w-4/5"
              >
                {{ item.artistName }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- 分页组件 -->
      <nav
        v-if="!isMobile()"
        class="flex w-full justify-center mt-3 mx-auto mb-3"
      >
        <!-- current-page 当前页 page-size 每页多少条 total 总条数 sizi-change 每页显示多少条事件 -->
        <el-pagination
          v-bind="pageConfig"
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          @change="handleChange"
        />
      </nav>
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