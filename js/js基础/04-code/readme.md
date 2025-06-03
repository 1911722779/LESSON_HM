# 函数
  - 实现代码的复用
  - function 是执行特定任务的代码块

  ## 函数的声明
    - function 函数名(){
      函数体
    }
    - 函数名和变量命名基本一致，尽量小驼峰式命名法，前缀应为动词
  
  ## 函数的参数
    - 形参

    - 实参
      // 求 n ~ m 的累加和
      function getSum(n=0,m=0){
        let sum = 0
        for (let i = n; i <= m; i++) {
          sum += i
        }
        console.log(sum)
        
      }
      let num1 = +prompt('请输入起始数字')
      let num2 = +prompt('请输入结束数字')
      getSum(num1,num2) // 实参可以是变量

  ## 函数的返回值
    function fn(){
      return 20
    }
    console.log(fun()) // 相当于执行了 fn() = 20

# 作用域
  ## 全局作用域
    作用于所有代码执行的环境（处于 script 标签内部的）或者一个独立的js文件
  ## 局部作用域
    作用于函数内的代码环境，就是局部作用域。因为跟函数有关系，所以也成为函数作用域
  ## 特殊情况
    如果函数内部，变量没有声明而是直接赋值，也会被当作全局变量，不推荐
    函数内部的形参可以看作是局部变量
    
# 匿名函数
  ## 函数表达式：将匿名函数赋值给一个变量，并通过变量名称进行调用
    let fn = function () {
      // 函数体
    }
    // 调用
    fn()

    - 匿名函数的调用一定在声明之后，即先声明再调用

    - 具名函数的调用可以在任何位置
      // 函数表达式和具名函数的不同 function fn (){}
      // 具名函数的调用可以写到任何位置
      fun() // 调用
      // 声明
      function fun() {
        console.log('我是具名函数');
      }
  
  ## 立即执行函数
    - 避免全局变量之间的污染
    - 立即执行函数一定要用分号（;）结束
    - 函数名可写可不写
    - (function 函数名(形参) { 
      // 函数体 
      })
      // 调用函数
      (实参);
      所以可以写成： (function (){})(); 注意要带分号
      或者可以写成： (function (){}()); 注意要带分号
      (function (){
        console.log(11);
      });
      (function(){
        let num = 10
      })();
      (function(){
        let num = 20
      })();

# 逻辑中断
  ## 短路
    - 只存在于 && 和 || 中，当满足一定条件会让右边代码不执行
      - && ： 左边为 false就短路，两边为真则返回后一个真值
        console.log(false && 3+5); // 返回false
        console.log(3+5 && false); // 返回false
      - || ： 左边为 true就短路，两边为真返回第一个真值
        console.log(false || 3+5); // 返回3+5
        console.log(3+5 || false); // 返回3+5

# 转换布尔型
  - 除 '', 0, null, undefined, NaN 外都为真 
    console.log(Boolean('')); // false
    console.log(Boolean(0)); // false
    console.log(Boolean(null)); // false
    console.log(Boolean(undefined)); // false
    console.log(Boolean(NaN)); // false
