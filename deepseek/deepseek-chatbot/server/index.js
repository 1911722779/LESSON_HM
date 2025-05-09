// commonjs
// node 最简单的后端框架
const koa = require('koa');
// 实例化
const app = new koa(); // 也是应用
const Router = require('koa-router'); // 路由
const router = new Router(); // 实例化
// 引入 axios
const axios = require('axios')
// 新建'/'路由
router.get('/',async (ctx) => {
    // 响应体
    // ctx为这一次请求响应的上下文
    // 有一个用户做出请求，ctx就是用户请求的上下文，服务器给出响应文本
    ctx.body = `
        <html>
            <head>
                <title>chatbot</title>
            </head>
            <body>
                <h1>chatbot</h1>
            </body>
        </html>
    `;
})
// 新建一个叫做chatai的路由
// method, url
// post 
// 后端 返回api接口数据 json
// nest.js
// 前端react axios 向 /chatai 发送post请求
router.post("/chatai",async(ctx) => { // 表达加密请求
    // 前端 input 传过来的内容message
    // 向ollama 11434/api/chat 发送post请求
    // chatgpt 是行业标准
    const message = 'hello'
    const data ={
        model:"deepseek-r1:1.5b",// 必须指定模型，本地不止一个模型，不指定不知道用什么
        message:[
            {
            role:"user",
            content:message
            }
        ],
        stream: false
    }

    // 使用axios向ollama发送请求 axios是封装的fatch更简单 转发请求
    // 收到请求后将请求转发给ollama，ollama使用deepseek模型给予回答
    // AI 能力集成
    const response = await axios // 前方使用了async
      .post("http://localhost:11434/api/chat",data)
      .then(response => {
        console.log(response.data); // 大模型的回复在这里打印
      })


    ctx.body={
        code: 200,
        message:'我是一个机器人'
    }
})
// 路由的挂载app
app.use(router.routes());

app.listen(3000,() => {
    console.log("server is running at port 3000");
    
})