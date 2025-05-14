- git 有哪些命令？
  版本控制软件 多人协作
  写项目 电脑坏了 保存代码的版本且安全，团队代码的协作
  git 帮我们在本地 管理代码版本，远程仓库（分布式）
  常用操作，自我代码管理和简单的协作
  - git init 初始化
  把代码加入仓库分三步
  - git add . 
  - git commit -m ""
  - git push origin main
    git push -u origin main
  - git branch 分支
  - git checkout 切换分支
  - git merge 合并分支

## 需要的git 能力？
  - git 是必备技能
  - 高级技能 考点
  - git 文档内齿
    git help 常用的git 命令
    git help -a 列出所有的名单
    vi 编辑器  :j :k 上下翻页  :q 退出浏览
    git help add   深入了解某个命令
    你是如何了解git 命令的作用和参数的？

## 代码仓库
  文件夹 -> 开发目录（网站） -> 代码仓库
  - 好处
    项目代码的版本(version)  git关注的是代码的版本 
    时光穿梭机 可以让文件回到的任何版本 有时候我们需要回退
  - git 仓库里存的是什么东西
    文件的版本
    拿着相机一直拍
    .git 目录就是仓库
    git 相关内容就放在.git 目录里 
  - git config 配置 操作留下了责任人，多人协作的思想 设置提交人的名字或昵称
    git config --global user.name""
    git config --global user.email""
    nano ~/.gitconfig  进入全局设置,可以在git bash中改变全局提交人昵称和邮箱 
    --global 配置 全局

  - git status 
    反馈当前仓库的状态
    on branch main 主分支上（默认分支）
    untracked file 未跟踪的文件 还没有纳入版本管理
    use conmmit 

  添加到仓库是一件比较严谨的事情
  - git add file
    将文件的当前版本添加到暂存区 
    git status 
    git commit -m '' 为添加进仓库写一个注释

  - 为什么需要暂存区， 仓库 两个概念
    - 后悔药
    - 分几次add,然后一次性commit
      多次git add 一次git commit
  - git remote -v 
    查看当前仓库的地址
  - git remote add origin 仓库地址
    添加仓库地址
  - git remote set-url origin 仓库地址
    重新设置仓库地址
  - git log
    代码提交记录
    --oneline 一行显示
  
  - 暂存区 仓库
    - 一次性多个文件多次修改，多次加入暂存区
    - 一次commit -m 要规范 讲清楚任务
    - 不要随便提交commit ,围绕开发需求
  