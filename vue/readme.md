1. npm i
2. npm init -y
3. npm i
4. vue creat vue-app
5. git push -u origin main
6. git checkout -b develop 创建develop分支并切换到develop

# Jar_Music 简介
使用vue3搭建
开发环境：node v20.13.1, npm 10.5.2
nvm的使用: nvm list 查看已有的node版本号
          node -v 查看正在使用的node版本号
          nvm use 版本号 使用该版本号的node

```sh
  # 使用pnpm 替代 npm
  1. npm install pnpm

  # 构建过程中可能出现 Windows 拦截禁止脚本运行
  npm : 无法加载文件 D:\node\npm.ps1，因为在此系统上禁止运行脚本。有关详细信息，请参阅 https:/go.microsoft.com/fwlink/?LinkID=135170 中的 about_Execution_Policies。 所在位置 行:1 字符: 1 + npm install -g pnpm + ~~~     + CategoryInfo          : SecurityErro

  # 执行
  # 方案1
  Set-ExecutionPolicy Unrestricted
  # 方案2 当前用户已经修改过策略，直接覆盖
  Set-ExecutionPolicy Unrestricted
```

## 6.24

### 登录 注册 找回密码功能实现

文件所在路径 `src/components/Auth/AuthTabs.vue`

components 路径一般来说，在前端工程中，不是单独的页面，但是具有通用属性，经常需要复用，这就是组件。组件会单独存放在一个目录中，与页面存放的路径区分开

vue文件 统一分为三个区域：
1. 脚本区域 写逻辑代码的地方
2. 页面展示区域 浏览器渲染的地方
3. 样式区域 写CSS的地方

`<script setup lang="ts">`
setup 是vue3语法 显示声明 组合式API
lang 声明语法 声明这个脚本是哪一种语言 此处为TypeScript

前端工程中 API接口定义 一般放在api文件下 存放的是所有后端的接口地址方法


Vue 中子父组件船只
AuthTab 父组件 el-tabs 是页签组件，具有切换功能
LoginForm 子组件 时间透传，需要子组件通知 父组件可以切换了


页面中常见的布局方式
1. 绝对布局 绝对定位
2. 相对布局 A相对于B A在B的什么位置
3. flex布局 弹性布局

Vue3中所有的变量 都要用ref() 函数包裹 指代这个变量是一个响应式

Vue3中所有的数组 都要用reactive() 函数包裹

## 6.25

vue-router 组件 负责页面切换
localhost ：8090/library ==> library/index.vue

vue中所有的路由、地址与地址映射关系表，都在 `routers` 文件夹下


## 6.26
遇到问题：
1. 菜单栏 动态生成之后 默认的属性不能生效
2. 网格布局不能滑动
解决问题：
1. 菜单栏有默认属性且生效
2. 网格布局可滑动
3. 组合查询

## 6.27
遇到问题：
组合搜索虽然可以通过记录上一次的queryParams数据缓存实现，但是存在用户无法得知自己的选择条件是否生效或者符合自己的筛选方向，这种交互逻辑存在问题
如何解决：
根本原因时ElementUI菜单是无法多选的 
1. 换掉ElementUI
2. 手动生成菜单，让每个菜单独立（复制多份菜单）
3. 通过另外一个方式显示已选的条件 

完成歌单页面
1. 使用flex布局
2. 下拉框 页签 网络布局 分页组件

```ts
API 接口
/** 获取推荐歌单 */
export const getRecommendedPlaylists = () => {
  return http<Result>('get', '/playlist/getRecommendedPlaylists')
}
```

## 6.28 
搜索可以分为前端过滤搜索 以及后端接口搜索
1. 前端过滤搜索 
   优点： 节省服务器资源 降低服务器的压力 
   缺点： 在大业务场景下 容易出现数据不一致 实现起来比较麻烦
2. 后台接口搜索
   优点： 数据一致性比较强 实现起来比较简单

路由跳转页面 传递了歌单的ID到对应的页面
如何在对应的页面获取到上一个页面路由传递过来的参数呢

router 路由 发送数据，也可以接收数据

## 6.30
使用`mitt` 用于跨组件船只，调用方法
因为Vue 支持子父组件传值 后代组件传值 兄弟组件传值


## 7.1
剩余需求
1. 曲库搜索功能
2. 歌手详情页
3. 用户自建歌单
4. 歌曲收藏页
5. 排行榜页
6. 个人中心页
7. 歌词功能
8. Table组件 需要新增添加到歌单的功能