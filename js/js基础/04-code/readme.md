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
  - 全局作用域
    作用于所有代码执行的环境（处于 script 标签内部的）或者一个独立的js文件
  - 局部作用域
    作用于函数内的代码环境，就是局部作用域。因为跟函数有关系，所以也成为函数作用域
  - 特殊情况
    如果函数内部，变量没有声明而是直接赋值，也会被当作全局变量，不推荐
    函数内部的形参可以看作是局部变量
    