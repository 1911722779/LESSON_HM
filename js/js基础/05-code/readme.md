# 对象
  - 对象(object)
  - 可以理解为时一种无需的数据库集合，注意数组是有序的数据集合
    let jar = {
      'name - jar':'jar',
      uname: 'jar',
      age: 19,
      gender: '女'
    }
    console.log(jar)
    console.log(typeof jar)
    // 将gender改为男
    jar.gender = '男'
    console.log(jar)
    // 删除age
    delete jar.age
    console.log(jar)
    // 查
    console.log(obj['name - jar'])

  let phone = {
    name: '小米14',
    num: '100012312340',
    weight: '0.55kg',
    address: '中国大陆'
  }
  phone.price = '3999元'
  console.log(phone)
  console.log(phone.price) // 输出3999元

  ## 对象中的方法
    let jar = {
      uname: 'jar',
      age: 19,
      gender: '女',
      // 方法
      sayHello: function() {
        console.log('hello');
      }
    }
    // 方法的调用
    jar.sayHello()

  ## 对象的遍历
    ### for in
    let arr = ['a','b','c','d','e']
    for (let k in arr) {
      // console.log(typeof k);
      console.log(k); // 数组的下标 索引号 但是为字符串string
      console.log(arr[k]);
    }
    let obj = {
      name:'jar',
      age:18,
      gender:'女'
    }
    // 遍历对象
    for (let k in obj) {
      console.log(k); // 输出的k为属性名,为'属性名'
      console.log(obj.k) // 输出为undefined
      console.log(obj['name']) // 输出为jar
      console.log(obj[k]) // 输出为属性值 
    }
    ### for i
        let students = [
      {
        name: 'jar',
        age: 19,
        gender: '女',
        hometown: '江西省'
      },
      {
        name: '小明',
        age: 19,
        gender: '男',
        hometown: '河南省'
      },
      {
        name: '小红',
        age: 19,
        gender: '女',
        hometown: '浙江省'
      }
    ]
    for (let i = 0;i < students.length; i++) {
      console.log(students[i].name)
      console.log(students[i].age)
      console.log(students[i].gender)
      console.log(students[i].hometown)
    }