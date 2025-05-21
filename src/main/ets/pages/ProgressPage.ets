@Entry
@Component
struct ProgressPage {
  @State message: string = 'Hello World';

  build() {
    /**
     *  Progress
     *    进度条 线性进度条 圆形进度条
     *    value 实际值
     *    total 最大值
     *    type 类型 枚举变量类型：ProgressType Linear（线性） | Ring（环形无刻度）
     *
     *    style 样式
     *      strokewidth 进度条宽度
     *    color 进度条颜色
     */
    Column(){

      Progress({
        type:ProgressType.Ring, // 进度条类型
        total:100, // 进度条最大值
        value:50 // 进度条实际值
      })
        .style({
          strokeWidth:10,
        })
        .color('#C1B2A3')

      /**
       *  UI组件 图片 文本 进度条 单选 切换 文本域
       *  容器组件 承载UI组件 循环渲染
       *  布局组件 布局
       *
       *  轮播图
       *  Swiper 滑动容器组件 提供切换显示子组件能力
       *    Foreach 循环渲染
       *  List 列表组件
       */
      Swiper(){
        // 子组件 图片
        Image('https://ts1.tc.mm.bing.net/th/id/R-C.b20b5c20c4736df34da23feab38bb0cb?rik=TSWz%2b2J9B1qnrg&riu=http%3a%2f%2f5b0988e595225.cdn.sohucs.com%2fimages%2f20190724%2ffe93ebf2e39b44b2b1aab258e0a1b6b3.jpeg&ehk=Voeu3gV1H9YtOI5BjHCztvPxfQpakzL137crA9DZth0%3d&risl=&pid=ImgRaw&r=0')
        Image('https://pic.nximg.cn/file/20230429/33458386_091216220123_2.jpg')
      }
      /**
       *  自动播放 autoplay
       *  循环播放 loop
       *  指示器 indicator 默认开启
       *  时间间隔 interval(单位ms）
       *
       */
      .autoPlay(true)
      .loop(true)
      .height(300)
      .interval(3000)


    }
    .width('100%')
    .padding(100)
  }
}