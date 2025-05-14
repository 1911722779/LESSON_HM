# 面向 Openai 接口编程

- 多模态
  - 单模态
    chatgpt 文本
  - 图片、视频、音频

- npm init -y 后端
  npm i openai    openai的 sdk
  - 若安装失败：npm config set registry https://registry.npmmirror.com
    国内镜像npm 设置了npm的源，npm 是国外的， 很慢，阿里做了国内的npm镜像 提速

  - 花时间 占用空间
    npm i -g openai 全局安装 占用空间少 时间长（不推荐，很容易造成全局环境污染

- npm i -g pnpm
    pnpm 一个快速、节省磁盘空间的npm包管理器，它通过使用符号链接来避免重复下载相同的包
    pnpm --version 查看当前版本
    在哪里使用？ 可以在命令行直接调用  环境变量？  污染全局

- 既不会重复安装，也不会污染全局，使用符号链接去指向之前的安装
  快速且省空间 pnpm

- pic 文件夹中的node-modules文件夹删去 这是旧时代的安装方式，没有用处

- pnpm i openai

- mian.mjs 主入口，单点入口的职责  
  mjs es6 module import from

- 调适能力
  console.log(result) 查看它的json结构

- 理解参数 
  gpt4o 多模态读图能力
    - 文本指令
    - 图片地址

- try catch
  容错

- key 不能提交到github
  资产的安全风险