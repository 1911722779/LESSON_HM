# 运算符
1. 赋值运算符
  '='
2. 比较运算符
  '>' '<' '>=' '<='
  '==' 左右两边的值是否相等
  '===' 左右两边的值和类型是否相等 
    console.log(3 > 5) // 返回false
    console.log(3 >= 3); // 返回true
    console.log(2 == 2); // 返回true
    // 比较运算符有隐式转换
    console.log(2 == '2'); // 返回true
    console.log(2 === '2'); // 返回false
    console.log(2 === 2); // 返回true
    console.log(NaN === NaN); // 返回false
        console.log('--------------------------------');
    // 比较 ASCII 码值
    console.log('a' < 'b'); // 返回true
    console.log('a' > 'b'); // 返回false
    console.log('aa' > 'ab'); // 返回false
    console.log('aa' < 'aab'); // 返回true
    console.log('--------------------------------');
3. 逻辑运算符
    1. && 逻辑与
    2. || 逻辑或
    3. ! 逻辑非

# if 语句
1. if单分支语句
  1. 除了0 所有数字都为真
  // 此处不执行
  if (0) {
    console.log('执行语句')
  }
  2. 除了空字符串都为真
  // 此处不执行
    if ('') {
    console.log('执行语句')
  }
2. if双分支语句
  if(){

  }else{

  }
3. if多分支语句
  if(){

  }else if{

  }else if{

  }else{

  }

# 三元运算符
  条件 ? 满足条件执行的代码 : 不满足条件执行的代码
    // 条件 ? 代码1 : 代码2
    let num = 10
    let result = num > 0 ? '大于0' : '小于0'
    console.log(result)
    console.log(3 > 5 ? 3 : 5)
    // if(3 < 5 ){
    //   alert('真的')
    // }else{
    //   alert('假的')
    // }
    3 < 5 ? alert('真的') : alert('假的')

# switch 语句
  switch(数值) {
    case 数值1:
        代码1
        break;
    case 数值2:
        代码2
        break;
    case 数值3:
        代码3
        break;
    default:
        错误数据触发default
        break;
  }

# while 循环
  while(true){
    
  }