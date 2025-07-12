<script setup lang="ts">
import { getAllSongs } from '@/api/system';
import { isMobile } from "@/utils";
import { Search } from '@element-plus/icons-vue';
import { FormInstance } from 'element-plus';
// 本地歌曲列表缓存 负责减少服务器渲染压力 
const libraryStore = useLibraryStore()

//表单引用
const formRef = ref<FormInstance>()

// 查询参数表单
const queryParams = reactive({
  //歌曲名称
  songName: null,
  //歌手名称
  artistName: null,
  //专辑名称
  album: null
})
// 曲库列表 
const tableData = computed(() => libraryStore.tableData)
/**
 *  v-model:current-page="currentPage"
    v-model:page-size="pageSize"
    @size-change="handleSizeChange"
    @current-change="handleCurrentChange"
 */
//当前页 默认第一页
const currentPage = ref(1)
// 每页显示多少条 默认15条
const pageSize = ref(15)


//定义一个统一配置 让 分页组件绑定这个配置 reactive针对复杂对象响应式
const pageConfig = reactive({
  size: 'default',
  disabled: false,
  background: false,
  layout: 'total, sizes, prev, pager, next, jumper',
  total: 0,
  pageSizes: [15, 30, 45],
})

//每页显示条数 变更事件
const handleSizeChange = async () => {
  await getAllSongData()
}
//当前页码 变更事件
const handleCurrentChange = async () => {
  await getAllSongData()
}


//获取所有歌曲数据 分页获取 一次性获取 10-50条用渲染
const getAllSongData = async () => {
  /**
   *  告知当前是第几页  page
   * 509 ==>  10条一次获取 就有51页
   * 第一页 1-10 
   * 第二页 11-20
   * 
   * 每页多少条 size
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
    album: queryParams.album || null
  })

  
  if (result.code === 0 && result.data) {
    // tableData.value=result.data
    //result.data 
    // items ==> Array
    // total 数据总数
    console.log("歌曲名称",queryParams.songName)
    
    console.log(result.data)
    
    //从服务器获取的数据 丢到缓存中存储
    libraryStore.setTableData(result.data)
    //告知分页组件 总条数 让分页组件计算页码和页数
    pageConfig.total = result.data.total || 0

  }
}

// 提交查询表单
const submitForm = async (formEl: FormInstance | undefined) => {
  //1. 携带条件查询数据
  await getAllSongData()
}

// 重置表单
const resetForm = async (formEl: FormInstance | undefined) => {
  if (!formEl) return
  formEl.resetFields()
  currentPage.value = 1
  // 可以选择重置pagesize，但是不推荐
  // pageSize.value = 15
  await getAllSongData()
}

onMounted(async () => {
  await getAllSongData()
})
</script>


<template>
  <!-- 
      flex 弹性布局 
      flex-col  列布局
      flex-1  1列 
      h-full   高度拉满
      overflow-hidden 溢出隐藏
    -->
  <div class="flex flex-col flex-1 h-full overflow-hidden p-5 mr-4">

    <!-- 搜索功能栏 -->
    <div class="flex flex-row mb-5 gap-x-2 ">

      <el-form inline="true" :model="queryParams" size="large" ref="formRef">

        <el-form-item label="歌曲名称" prop="songName">
          <el-input v-model="queryParams.songName" class=" w-48" placeholder="请输入歌曲名称" />
        </el-form-item>

        <el-form-item label="歌手名称" prop="artistName">
          <el-input v-model="queryParams.artistName" class=" w-48" placeholder="请输入歌手名称" />
        </el-form-item>

        <el-form-item label="专辑名称" prop="album">
          <el-input v-model="queryParams.album" class=" w-48" placeholder="请输入专辑名称" />
        </el-form-item>

        <!-- 查询按钮与 重置按钮 -->
        <el-form-item>
          <el-button type="primary" @click="submitForm(formRef)" :icon="Search">
            查询
          </el-button>
          <el-button @click="resetForm(formRef)">重置</el-button>
        </el-form-item>

      </el-form>

    </div>
    

    <!-- 曲库 实际就是 表格
          表头  th
          表体  tbody
                th  tr
          表底部  tfoot
        -->

    <!-- 歌曲列表 有 PC端 和 移动端 -->

    <!-- PC端 el-table  :data="tableData?.items"   -->
    <Table class="flex flex-1 overflow-hidden" v-if="!isMobile()" :data="tableData?.items"></Table>

    <!-- PC端分页组件 -->
    <nav v-if="!isMobile()" class="flex w-full justify-center mt-3 mx-auto mb-3">
      <!-- current-page 当前页  page-size 每页多少条  total 总条数
                  size-change 每页显示多少条事件 current-change 当前页码发生变化事件-->
      <el-pagination v-bind="pageConfig" v-model:current-page="currentPage" v-model:page-size="pageSize"
        @size-change="handleSizeChange" @current-change="handleCurrentChange" />

    </nav>

    <!-- 移动端 -->
    <MobileList v-if="isMobile()" :page="'library'"></MobileList>



  </div>
</template>