@Entry
@Component
struct RelativePage {
  @State message: string = 'Hello World';

  build() {
    /**
     *  Relativelayout 相对布局
     *
     *  元素可以指定兄弟元素 或者父元素为锚点，基于这个锚点来描述位置关系
     *   1. 参考边界： 设置组件的某个边界对齐锚点
     *   2. 锚点： 通过锚点设置当前元素是基于哪个元素确定的位置
     *     2.1 默认锚点为当前元素的父容器 __container__
     *   3. 对齐方式： 设置当前元素是基于锚点的上中下对其 或 左中右对齐
     *
     */
    RelativeContainer(){
      Text("2025.5.7").id("t1")
      Text("11.08").id("t2").alignRules({
        // t2 的左边界设置
        left:{
          // 左边界相对于t1
          'anchor':'t1',
          // 向t1右边进行水平方向对齐
          'align':HorizontalAlign.End

        }
      })

      Text("11.19").id("t3").alignRules({
        // t3 的上边界设置
        top:{
          // 左边界相对于t1
          'anchor':'t1',
          // 向t1下边进行垂直方向对齐
          'align':VerticalAlign.Bottom
        }
      })
        // 单独设置组件位置偏移量 x,y
        .offset({
          x:15,
          y:15
        })
    }
    .height('100%')
    .width('100%')
  }
}