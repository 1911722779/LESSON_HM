@Entry
@Component
struct CardPage {
  @State message: string = 'Hello World';
  @State totalCount:number = 0;
  build() {
    Column(){
      List(){
        ForEach([1,1,1,1,1,1,1,1,1,1],(val:number)=>{
          ListItem(){
            Item({count:$totalCount})
          }
        })
      }
    Text("总数："+ this.totalCount)
    }
    .height('100%')
    .width('100%')
  }
}

@Component
export  struct  Item{
  @Link count:number
  build() {
    Column(){
      Image('https://img12.360buyimg.com/n1/s450x450_jfs/t1/291864/25/6633/9218/6825bae6F49870da5/8018888097e9ca6b.jpg').width('100%')
      Button("加入购物车").onClick(()=>{
        this.count++
      })
    }
    .width(150)
    .height(200)
  }
}