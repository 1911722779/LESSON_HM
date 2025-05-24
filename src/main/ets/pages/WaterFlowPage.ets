/**
 *  商品接口
 */
interface  Produce{
  img:string,
  title:string
}

@Entry
@Component
struct WaterFlowPage {
  @State array:Array<Produce>=new Array;

  /**
   *  @Entry 页面生命周期
   *
   *  onPageShow 页面每次 显示 的时候触发一次 页面 跳转 会触发 后台切换到前台的时候也会触发
   *  onPageHide 页面每次 隐藏 的时候触发一次 页面 跳转 会触发 前台切换到后台也会触发
   *  onBackPress 用户点击返回触发
   */
  onPageShow(): void {
    console.log("page show")
  }
  // @Component 组件 生命周期函数 页面创建时触发
  /**
   *  aboutToAppear 组件被创建的时候调用创建组件实例 会在build函数之前执行 一般用于初始化数据
   *  onDidBuild build函数执行后一般也是数据上报 数据更新场景 不建议更新变量的状态
   *  aboutToDisappear 组件被销毁之前执行
   */
  /**
   *  组件与页面声明周期顺序
   *
   *  aboutToAppear
   *
   *  build
   *
   *  onDidBuild
   *
   *  onPageShow
   *
   *  onPageHide
   *
   *  aboutToDisappear
   *
   */

  /**
   *  生命周期函数 页面创建时触发
   */
   aboutToAppear(): void {
     console.log("aboutToAppear")
     // 1. 赋值
     // 2. for + push
     for(let i = 0; i < 10; i++){
       this.array.push({
         img:'https://img1.360buyimg.com/n6/jfs/t1/273551/19/24393/42850/68061b69Ff612703c/13777afd56e263f1.jpg',
          title:'vivo X200 Ultra V单相机 蔡司三大定焦大师镜头 骁龙8至尊版 演唱会神器手机'
       })
     }
   }

@Builder
itemFooter(){
    Row(){
      LoadingProgress().width('30%')
      Text("正在加载").fontSize(20)
    }
    .width("100%")
    .justifyContent(FlexAlign.Center)
}

  /**
   *  瀑布流布局
   *  WaterFlow
   *  在网格布局基础上进行增强
   *  columnsTemplate 控制列数
   *  rowsTemplate 控制行数
   *
   *  FlowItem
   *
   */
  build() {
    WaterFlow({
      // 1. 瀑布流支持加载状态自定义
      footer:this.itemFooter(),
      // 2. 布局模式 元素按照列优先或行优先的方式依次排列，形成一种“瀑布”效果
      //    列表中的项目将总是从顶部开始向下填充
      layoutMode:WaterFlowLayoutMode.ALWAYS_TOP_DOWN
    }){
      ForEach(this.array,(val:Produce)=>{
        FlowItem(){
          Column(){
            Image(val.img)
              // 高度的随机 模拟图文混排
              .height(Math.random()*30+197)
            Text(val.title)
          }
        }
      })
    }
    // 控制瀑布流布局为 2 列
    .columnsTemplate("1fr 1fr")
    .height('100%')
    .width('100%')
    // 触底事件 触顶事件
    .onReachEnd(()=>{
      setTimeout(()=>{
        // 新增数据
        for(let i = 0; i < 10; i++){
          this.array.push({
            img:'https://img1.360buyimg.com/n6/jfs/t1/273551/19/24393/42850/68061b69Ff612703c/13777afd56e263f1.jpg',
            title:'vivo X200 Ultra V单相机 蔡司三大定焦大师镜头 骁龙8至尊版 演唱会神器手机'
          })
        }
      },1000)


    })
  }
}