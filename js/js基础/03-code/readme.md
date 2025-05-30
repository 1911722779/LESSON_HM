# for 循环

# 数组
  - 最大值最小值
    let arr = [1,2,3,4,5]
    let max = arr[0]
    let min = arr[0]
    for (let i = 0; i < arr.length; i++) {
      if (arr[i] > max) {
        max = arr[i]
      }
      if (arr[i] < min) {
        min = arr[i]
      }
    }
    console.log("最大值是："+max+"最小值是："+min);
    for (let i =1; i < arr.length; i++) {
      max < arr[i] ? max = arr[i]:max
      min > arr[i] ? min = arr[i]:min
    }
    console.log(`最大值是： ${max}`);
    console.log(`最小值是： ${min}`);
  
  - 修改数组
    let arr =['jar', 'pink','gray','white','black']
    arr[1] = 'red' // 改
    // 给所有数组元素后面加个‘老师’ 修改
    for(let i = 0; i < arr.length;i++){
      arr[i] += '老师'
    }
    console.log(arr);

  - 添加数据
    let arr = ['jar','pink']
    // 新增 直接在数组末尾新增数据
    arr.push('white')
    console.log(arr) // ['jar', 'pink', 'white']
    // 开头追加
    arr.unshift('black')
    console.log(arr); // ['black', 'jar', 'pink', 'white']

  - 删除数据
    // 删除
    let arr= ['jar','pink','black','white','gray']
    // 删除最后一个元素
    arr.pop()
    console.log(arr); // ['jar', 'pink', 'black', 'white']
    // 删除第一个元素
    arr.shift()
    console.log(arr); // ['pink', 'black', 'white']
    // 删除指定位置的元素 splice(起始位置，删除元素数量)
    arr.splice(2,1)
    console.log(arr); // ['pink', 'black']
# 数组筛选
  - 筛选数字
    let arr = [2,0,6,1,77,9,54,3,78,7]
    // 声明新的空数组
    let newArr = []
    for (let i = 0; i < arr.length; i++) {
      if(arr[i] >= 10){
        newArr.push(arr[i])
      }
    }
    console.log(newArr);
  
  - 数组去0案例
    let arr = [2,0,6,1,77,9,54,3,78,7]
    // 声明新的空数组
    let newArr = []
    // 遍历筛选
    for (let i= 0; i< arr.length;i++){
      if( arr[i] !== 0) {
        newArr.push(arr[i])
      }
    }
    console.log(newArr)

# 冒泡排序
  - 简单冒泡
    let arr=[5,4,3,2,1]
    for(let i=0;i<arr.length-1;i++){
      for(let j=0;j<arr.length-1-i;j++){
        if(arr[j]>arr[j+1]){
          let temp=arr[j]
          arr[j]=arr[j+1]
          arr[j+1]=temp
        }
      }
      console.log(arr);
    }
    console.log(arr);
  
  - sort() 升序排序
    arr.sort()
    console.log(arr);
  
    arr.sort(function(a,b){
      return a-b // 由小到大
    })
    console.log(arr);

  - sort() 降序排序
    arr.sort(function(a,b){
      return b-a // 由大到小
    })
    console.log(arr);