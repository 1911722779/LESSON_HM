<script setup lang="ts">
import { Search,Refresh } from '@element-plus/icons-vue'
import { getAllSongs } from '@/api/system'
import { isMobile } from '@/utils'
import { FormInstance } from 'element-plus'

// 本地歌曲列表缓存 负责减少服务器渲染压力
const libraryStore = useLibraryStore()
// 曲库列表
const tableData = computed(
  () =>
    // 从缓存列表中读取一次曲库列表
    libraryStore.tableData
)
// 当前页默认第1页
const currentPage = ref(1)
// 每页显示15条
const pageSize = ref(15)

// 定义一个统一配置 让分页组件版内搞定这个配置
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: 0,
  pageSizes: [15, 30, 45],
})

// 查询参数表单
const queryParams = reactive({
  // 歌曲名称
  songName: null,
  // 歌手名称
  artistName: null,
  // 专辑名称
  album: null,
})

// 每页显示条数的变更事件
const handleSizeChange = async () => {}
// 当前页码变更事件
const handleCurrentChange = async () => {
  getAllSongData()
}
// 获取所有歌曲数据 分页获取 一次性获取 10-50条用于渲染
const getAllSongData = async () => {
  /**
   * 告知当前是第几页
   * 若10条为一次获取，即10条为1页
   *
   * 每页的条数 size
   *
   */
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
    album: queryParams.album || null,
  })

  // 判断请求是否有效
  if (result.code === 0 && result.data) {
    // tableData.value = result.data
    console.log(result.data)
    // 从服务器获取的数据 丢到缓存中存储
    libraryStore.setTableData(result.data)
    // 告知分页组件 总条数 让分页组件计算页码和页数
    pageConfig.total = result.data.total || 0
  }
}
// 提交查询表单
const submitForm = async(formEl: FormInstance | undefined) => {
  // 1. 携带条件查询数据
  await getAllSongData()
}
// 重置表单
const resetForm = async(formEl: FormInstance | undefined) => {
  if (!formEl) return
  formEl.resetFields()
  await getAllSongData()
}

// 表单引用
const formRef= ref<FormInstance>()

onMounted(async () => {
  await getAllSongData()
})
</script>

<template>
  <!-- 
    flex 弹性布局
    flex-col 列布局
    flex-1 1列
    h-full 高度100%
    overflow-hidden 溢出隐藏 
  -->
  <div class="flex flex-col flex-1 h-full overflow-hidden p-5">
    <!-- 搜索功能栏 -->
    <div class="flex flex-row mb-5 gap-x-2">
      <el-form inline="true" :model="queryParams" size="large" ref="formRef">
        <el-form-item label="歌曲名称" prop="songName">
          <el-input
            v-model="queryParams.songName"
            class="w-48"
            placeholder="请输入歌曲名称"
            :prefix-icon="Search"
          ></el-input>
        </el-form-item>

        <el-form-item label="歌手名称" prop="artistName">
          <el-input
            v-model="queryParams.artistName"
            class="w-48"
            placeholder="请输入歌手名称"
            :prefix-icon="Search"
          ></el-input>
        </el-form-item>
        <el-form-item label="专辑名称" prop="album">
          <el-input
            v-model="queryParams.album"
            class="w-48"
            placeholder="请输入专辑名称"
            :prefix-icon="Search"
          ></el-input>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="submitForm(formRef)" :icon="Search">查询</el-button>
          <el-button @click="resetForm(formRef)" :icon="Refresh">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 曲库 实际就是一个表格
      表头 th
      表体 tbody
           th tr
      表底部 tfoot
    -->
    <!-- 歌曲列表 有PC端 和 移动端 -->
    <!-- PC端 el-table 
      :data="tableData ?. items 渲染,如果有则渲染
    -->
    <Table
      class="flex flex-1 overflow-hindden"
      v-if="!isMobile()"
      :data="tableData?.items"
    >
    </Table>
    <!-- PC端分页组件 -->
    <nav v-if="!isMobile()" class="flex w-full justify-center mt-3 mx-auto">
      <!-- current-page 当前页 page-size 每页多少条 total 总条数 sizi-change 每页显示多少条事件 -->
      <el-pagination
        v-bind="pageConfig"
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </nav>
    <!-- 移动端 -->
    <MobileList v-if="isMobile()" :page="'library'"> </MobileList>
  </div>
</template>