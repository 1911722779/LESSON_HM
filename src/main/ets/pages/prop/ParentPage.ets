import { ChildPage } from './ChildPage'

@Entry
@Component
struct ParentPage {
  @State count: number = 10

  build() {
    Column(){
      // 引入外部组件
      ChildPage({count:this.count}).padding({
        bottom:30
      })
      Row(){
        Text('父组件的值：'+this.count.toString()).padding({
          right:30
        })

        Button('+').onClick(()=>{
          this.count++;
        })
      }

    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}