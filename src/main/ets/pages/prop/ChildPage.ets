@Component
export struct  ChildPage {
  @Prop count: number = 1;

  build() {
    Column(){
      Row(){
        Text('子组件的值：'+this.count).padding({
          right:30
        })

        Button('+').onClick(()=>{
          this.count++;
        })
      }

    }

  }
}