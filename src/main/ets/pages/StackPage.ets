@Entry
@Component
struct StackPage {
  @State message: string = 'Hello World';

  build() {
    /**
     *  所有元素层叠摆放
     *  后一个元素会覆盖前一个元素
     *  Z轴控制层级关系
     *  层叠布局对齐方式 默认左上对齐 一共9种对齐方式 左上、左下、右上、右下，左右上下中
     *  zIndex内值越大，层级越高，层级最高的显示在最上层
     */

    // Stack(){
    //   // 元素1
    //   Column() {
    //   }
    //   .width('100%').height(150).backgroundColor('#F1B2A3')
    //   // 元素2
    //   Text('text').width('80%').height(30).backgroundColor('#F77').zIndex(1)
    //   // 元素3
    //   Image('https://pic.nximg.cn/file/20230429/33458386_091216220123_2.jpg')
    //     .borderRadius(100)
    //     .width(150).height(150)
    //     .zIndex(1)
    //   Image('https://i0.hdslb.com/bfs/seed/jinkela/short/user-avatar/big-vip.svg')
    //     .width(40).zIndex(4)
    //     .margin({top:110,left:100})
    //
    // }
    // .alignContent(Alignment.Top)
    // .width('100%')
    // .height('100%')

    Row(){
      Column(){
        Stack(){
          Image('https://pic.nximg.cn/file/20230429/33458386_091216220123_2.jpg')
            // 图片填充模式
            .objectFit(ImageFit.Cover)
            // 边框圆角
            .borderRadius(100)
            .width(100).height(100)
            .borderWidth(2)
            .borderColor(Color.Grey)
          Image('https://i0.hdslb.com/bfs/seed/jinkela/short/user-avatar/big-vip.svg')
            .width(30).zIndex(4)
        }.alignContent(Alignment.BottomEnd)
      }.layoutWeight(1)
      Column(){
        Text("重生之不想学软件工程")
          .fontWeight(FontWeight.Bold).fontSize(22)
        Text("橘子不是唯一的水果")
      }
      // 交叉轴
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(2)
    }
    .height(200)
    .width('100%')
  }
}