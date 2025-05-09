## 春招执行方案

- 时间
 3月-5月
- 大厂最容易
    - 语言能力
    - 面试能力
    - 算法
- 3、4月份 远程实习（AI远程实习）
    - 拿下一个offer
    - 慢慢找到实习，需要拿下的实习经验


## deepseek
- 性价比高
    aigc
    tokens 提问以及返回 百万只需一元 按token计费
- 为什么省
    - openai 堆算例 GPU
    - 新的算法 甚至可以绕开 英伟达 cuda 编程
    - DeepSeek V3 2048 块 H800 557.6万美元，meta llama3 是 deepseek 的11倍

## DeepSeek AI 全栈应用
  前端 + 后端 + LLM = AI fullstuck

- ai应用集合项目
  coze 工作流 + ai应用
  deepseek openai 的替代品 prompt
  langchain rag 应用开发

- react（chatbot）
- node koa 
- LLM 发送请求（deepseek）302.ai
  离线大模型的调用

  react <-> koa <-> LLM
- 大前端（前后端分离）前端写自己的页面，需要调用数据时，后端提供接口，后端不提供api接口时，就自行模拟数据
  - 前端包着后端
    - 前端
    domain：5173 
      - react 组件
    - 后端
    domain：3000 请求
      - koa 框架
      - http 服务 3000端口 伺服状态（等待服务的状态，随时待命）
      - 路由 /chatai 带上问题message ？
        - npm i koa-router (周边生态)  安装koa框架
        - 实例化路由对象 new Router()
        - router.Method('/path',async (ctx)=>{

        }) // 注册路由
        - ctx 上下文对象 request + response
        - ctx.body 设置响应体
    - 跨域 同源策略

- ollama
  - 302.ai ai 转发 online 大模型
  - 本地访问大模型的可能
    某大厂，开源的deepseek
    ollama pull deepseek-r1:1.5b 拉取到本地 offline 调用 
    模型的微调 根据自己的业务或需求，重新训练一下deepseek
  - ollama pull llama3.2:latest
  - const add = (x,y) => x+y 此为传统编程（命令式编程）
    LLM(巨大的参数) nlp + 全球的知识（机器学习） + transfomer机制 => AIGC 回答 大模型也是一种函数
- ollama run deepseek-r1:1.5 运行
  command line chatbot 
  全栈应用的方式来通信 
  - http://localhost:11434/api/chat
    - 在11434端口 端口伺服
    - /api/chat 以聊天的方式LLM 去响应
      /api/generate 以生成一个内容的方式LLM 去响应
    - http 请求支持 让deepseek在本地运行后把结果返回给我们 完成应用调用ollama去使用deepseek的模型，而不用走302.ai进行调用了

- 参数（处理问题的规模）尺寸
  内存（8G）显卡 等硬件相关
- 集成deepseek 能力 可以实现了

- koa
  路由定义好了，用函数的方式来处理从这个路由来的用户，参数校验、逻辑功能，程序向LLM往axios发送请求
  最后返回资源，结束请求