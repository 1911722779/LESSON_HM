/**
 * AppScope 应用级别资源目录
 * entry 入口模块
 * src
 *  main 源代码目录 存放页面 组件 ability
 *   ets expand typescript
 *   resource 模块级资源目录
 *     element 属性
 *     media 图片音视频资源
 *   rawfile 原始文件
 *
 * build-profile.json5 项目级别编译配置
 * oh-package.json5
 */

// 装饰器 标志是一个入口页面
@Entry
// 组件 表示这是一个组件
@Component
struct Index {
  // 定义变量与函数（功能函数，组件函数）
  // @State 双向绑定 变量监听
  @State message: string = 'Hello World';
  // 定义变量
  @State username:string=''
  @State password:string=''

  // webpack
  // git 项目管理 协作开发 版本管理
  // dev test pro

  // 声明式UI开发 函数式UI

  // 线性布局 层叠布局（覆盖，贴图的层叠关系） 栅格布局（屏幕宽高等分）

  // build函数中，有且仅有一个根容器（根组件）
  build() {
    /*
        行、列 Row Column
        * Row 元素摆放左右，间距也是左右
        * Column 元素摆放上下，间距上下
     */
    // space 设置间隙
    Column({space:20}) {

      // 1. string 字符串
      // 2. 读取资源变量 $r 引用资源变量app为根路径
      Text('zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz') // 组件声明
        .fontSize(30) // 属性方法 字体大小
          // .fontColor(Color.Pink)
        .fontColor('#F1B2A3')
        .textAlign(TextAlign.Center)
        .width('100%') // .width(100)
        .maxLines(2) //最大行数限定为2行
        .fontStyle(FontStyle.Italic) //斜体文本
          // 文本溢出处理，做成滚动效果
        .textOverflow({
          /*
                * MARQUEE 滚动
                * Ellipsis 省略号
                * Clip 省略
           */
          overflow:TextOverflow.Ellipsis
        })

      /*
          option 配置
       */
      Button('登录')
        .type(ButtonType.Capsule)
        .onClick(() => {
          // MVVM 视图(UI)与逻辑分离
          console.log('点击登录')
        })

      /*
          1. 读取本地资源  $r('app.media.app_icon')
          2. 读取网络地址 ctrl+d 复制选中行
       */
      Image($r('app.media.1')).width(120)

      /*
          * TextInput
          * 类型： 密码 明文文本 数字 号码 邮箱
          * 提示： placeholder/hint
       */
      TextInput({
        placeholder:'请输入账户'
      })
        .onChange((val)=>{
          console.log(val);
          this.username = val
        }) // 获取输入的数据
      TextInput({
        placeholder:'请输入密码'
      }).type(InputType.Password)

      /**
       *  Progress
       *    进度条 线性进度条 圆形进度条
       *    value 实际值
       *    total 最大值
       *    type 类型 枚举变量类型：ProgressType Linear（线性） | Ring（环形无刻度）
       *
       *    style 样式
       *      strokewidth 进度条宽度
       *      color 进度条颜色
       */

    }
    // 四个方向内边距
    // .padding(10)
    .padding({
      left:10,
      right:10
    })



  }


}