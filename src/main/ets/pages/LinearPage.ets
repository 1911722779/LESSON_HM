@Entry
@Component
struct LinearPage {
  @State message: string = 'Hello World';

  build() {
    /**
     *  LinearLayout 线性布局
     *  Row 水平布局
     *  Column 垂直布局
     *  space 间距
     */
    Column(){

      Column(){
      }
      .width('80%')
      .height(50)
      .backgroundColor('#F1B2A3')
      Column(){
      }
      .width('80%')
      .height(50)
      .backgroundColor('#A1B1')
      Column(){
      }
      .width('80%')
      .height(50)
      .backgroundColor('#F72')
    }
    // 主轴对齐方式
    .justifyContent(FlexAlign.End)
    // 交叉轴 控制元素水平、垂直 方向排列方式 具体方向与主轴方向有关
    .alignItems(HorizontalAlign.Start)

    .width('100%')
    .height('100%')

  }
}