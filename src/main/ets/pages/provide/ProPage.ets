@Entry
@Component
struct ProPage {
  @State message: string = 'Hello World';
  @Provide count:number=10
  build() {
    Column({space:10}){
      Text("祖先组件").fontSize(30).fontWeight(FontWeight.Bold)

      Row(){
        // Text("父组件").fontSize(30).fontWeight(FontWeight.Bold)
        Child()
      }
      Parent()
    }
    .width('100%')
    .height('50%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor("#f1c3f5")
  }
}
@Component
export struct Parent{
  build() {
    Column({space:10}){
      Text("父组件").fontSize(30).fontWeight(FontWeight.Bold)
      Child()
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor("#ffefeffc")
  }
}
@Component
export struct Child{
  @Consume count:number;
  build() {
    Column({space:10}){
      Text("子组件").fontSize(30).fontWeight(FontWeight.Bold)

      Row(){
        // 计数器
        Text("@Consume").fontSize(30).fontWeight(FontWeight.Bold)
        Counter(){
          Text(this.count.toString())
        }
        .onInc(()=>this.count++)
        .onDec(()=>this.count--)
      }

      .backgroundColor("#ff96f674")
    }
  }
}