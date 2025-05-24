@Entry
@Component
struct GridPage {
  @State message: string = 'Hello World';

  build() {
    /**
     *  网格布局
     *
     *  columsTemplate 设置列数 值为字符串的数列 （"1fr 1fr"）占两列fraction 按比例1：1
     *  rowsTemplate 设置行数 值为字符串的数列 （"1fr 1fr 1fr"） 占三行fraction 按比例1：1：1
     *  fr 的个数表示网格布局的几行几列
     *  ctrl+d 快速复制粘贴
     *
     *  行列间距
     *  .columnsGap(1)
     *  .rowsGap(1)
     *
     *  网格布局支持自定义设置单元格占比
     *  rowStart rowEnd 行占用跨度
     *  columnStart columnEnd 列占用跨度
     *  起始索引 0
     */
    Grid(){
      // 唯一指定子元素 单元格
      GridItem(){
        Text("1").fontSize(50)
      }
        .columnStart(0)
        .columnEnd(2)
        .backgroundColor("#ff2894bf")
      GridItem(){
        Text("2").fontSize(50)
      }.backgroundColor("#ff2894bf")
      GridItem(){
        Text("3").fontSize(50)
      }.backgroundColor("#ff2894bf")
      GridItem(){
        Text("4").fontSize(50)
      }
        .rowStart(0)
        .rowEnd(1)
        .backgroundColor("#ff2894bf")
      GridItem(){
        Text("5").fontSize(50)
      }.backgroundColor("#ff2894bf")
      GridItem(){
        Text("6").fontSize(50)
      }.backgroundColor("#ff2894bf")
      GridItem(){
        Text("7").fontSize(50)
      }.backgroundColor("#ff2894bf")
      GridItem(){
        Text("8").fontSize(50)
      }.backgroundColor("#ff2894bf")
      GridItem(){
        Text("9").fontSize(50)
      }.backgroundColor("#ff2894bf")
    }
    // 设置列数 1:2:3 占比
    .columnsTemplate("1fr 1fr 1fr")
    // 设置行数 1:1 占比
    .rowsTemplate("1fr 1fr 1fr 1fr")
    // 行列间距
    .columnsGap(1)
    .rowsGap(1)

    .height('100%')
    .width('100%')
  }
}