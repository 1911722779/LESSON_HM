import { createApp } from 'vue'
import App from './App.vue'
import router from './routers/index'
import Store from '@/stores'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import 'element-plus/dist/index.css'
import 'element-plus/theme-chalk/dark/css-vars.css'
import './style/index.scss'
import  VConsole  from 'vconsole'
const app = createApp(App)
//调试工具
// new VConsole()
// 路由
app.use(router)
// 状态管理
app.use(Store)
// ElementPlus
app.use(ElementPlus, {
  locale: zhCn,
})



app.mount('#app')
