# Javascript 介绍
## JavaScript基础
  - JS是一种运行在客户端的编程语言，实现人机交互效果
  - 作用
    - 网页特效
    - 表单验证
    - 数据交互
  - JS的组成
## JavaScript的书写位置
  - 1. 内部JavaScript 直接写在html文件里，用script标签包住
    - 将JavaScript代码放在HTML页面的底部附近通常是最好的策略
    - alert('你好，js') 页面弹出警告对话框
  - 2. 外部JavaScript 代码写在.js文件
  - 3. 行内
## JavaScript的输入与输出语法
  - 输出
    document.write('输出的内容，页面打印输出')
    alert('要输出的内容')
    console.log('输出日志，控制台打印')
  - 输入
    prompt('输入')
## 字面量（literal）
  数字字面量
  字符串字面量
  数组字面量
  对象字面量

# 变量
## 声明变量
  - let
  - var
    - 可以先使用再声明（不太合理）
    - 声明过的变量可以重复声明（不合理）
    - 没有块级作用域
  - const
## 变量的本质
  - 是程序在内存中申请的一块用来存放数据的小空间

# 数组
  - let 数组名 = []
  - 数组名.length 数组长度

# 常量
  - const
  - 常量声明时必须赋值
  - 常量不允许更改
  
# 数据类型
  `JS 是弱数据类型语言，只有在赋值之后才能确认数据类型`

  - 基本数据类型
    - number
      整数、小数、整数、负数
    - string
      - 拼接字符串:
        let age = 19
        document.write('我今年' + age + '岁')
      - 模板字符串: `${属性名}`
        let uname = prompt('请输入你的姓名:')
        let age = prompt('请输入你的年龄:')
        document.write(`大家好，我叫${uname}，我今年${age}岁了`)
    - boolean
      - true false 布尔型字面量
    - undefined 未定义型
      - 表示没有赋值
      - undefined + 1 的结果是 NaN(Not a Number)
    - null 空类型
      - 表示赋值了，但是内容为空
      - 把null作为尚未创建的对象
  - 检测数据类型
    - typeof  
  - 类型转换
    - prompt输入的数据默认为string类型
    - 隐式转换
      - '+' 只要其中一个加数是字符串，都会把另一个转换成字符串，但作为正号解析可以转成数字型
        console.log('123' + 1) 结果为1231 字符型
        console.log(123 + '1') 结果为1231 字符型
        console.log(typeof +'123') 结果为number
      - '-' '*' '/' 会把数据转成数字类型
        console.log(2-'2') 结果为0 number
    - 显式转换
      - 直接Number
        let str = '123'
        console.log(Number(str));
        console.log(Number('jar')); 结果显示为NaN，表示非数字
        let num = +prompt('请输入一个数字:')
        console.log(typeof num); 结果显示为number
      - parseInt 保留整数
        console.log(parseInt('12px')); 结果为12
        console.log(parseInt('12.3px')); 结果为12
      - parseFloat 保留小数
        console.log(parseFloat('12.3px')); 结果为12.3
        console.log(parseFloat('12px')); 结果为12
  - 引用数据类型
    - object 对象