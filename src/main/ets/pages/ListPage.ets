@Entry
@Component
struct ListPage {

  /**
   *  自定义组件
   *  1. 声明式
   *  2. @Builder
   *  作用：
   *  1. 组件复用
   *  2. 复杂布局的构建
   */
  @Builder itemHeader(index:string){
    // 自定义组件 用于显示分组头部信息
    Text(index).width('100%').backgroundColor("#f1f2f3")
  }

  /**
   *  列表布局 实现结构化 可滚动的列表信息
   *  List 容器
   *  ListItem 容器
   *  ListGroup 用于数据分组布局
   *
   */

  build() {
    List({space:10}){
      // 列表项 支持循环渲染
      // 第一个参数 数据源
      // 第二个参数 被遍历的值
      ForEach(['A','B','C','D','F','G','H','I'],(val:string)=>{
        // ListItem(){
        //   Text(val.toString())
        // }
        ListItemGroup({
          // 自定义组件 自动填充
          header:this.itemHeader(val)
        }){
          // 子组件
          // 只能有一个根布局
          ListItem(){

            Row(){
              Image($r("app.media.app_icon")).height(90)
              Text("文字").margin({
                left:10,
                right:10
              })
            }
          }
        }
      })
      // 列表组

      ListItemGroup(){
        // 子组件
        // 只能有一个根布局
        ListItem(){
          Row(){
            Image($r("app.media.app_icon")).height(90)
            Text("文字").margin({
              left:10,
              right:10
            })
          }

        }
      }
    }
      .padding({
        left:5,
        right:5,
        top:5,
        bottom:5
      })
      // 设置列表布局排版方向 用枚举表示 默认垂直方向Vertical
      .listDirection(Axis.Vertical)
      // 分组标题吸顶效果
      .sticky(StickyStyle.Header)
      .width("100%")
      .height("100%")
  }
}