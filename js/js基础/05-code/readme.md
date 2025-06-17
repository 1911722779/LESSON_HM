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