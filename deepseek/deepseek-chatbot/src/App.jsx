import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const chatApi = async (message) =>{
  // 请求行 method + url + hppt 版本
  // 从5173端口 -> 3000端口 跨域 同源策略 cors服务器端， jsonp
  const reponse = await axios.post('http://localhost:3000/chatai',
    // 请求体（当post存在时，post里面有请求体）
    message,{
      // 请求头（定义类型，配置设定）
      headers:{
        'Content-Type':'application/json'
      }
    }
  )
  return response.data;
}
// react 内置的 hooks 函数
const App = () => {
  // useEffect 不能直接使用 async await
  useEffect(() => {
    // 副作用 mounted updata unmounted
    // await chatApi()
    const callChatAPI = async () => {
      await chatApi({message:'你好'})
    }
    callChatAPI()
  })
  return(
    <div>
      App
      
    </div>
  )
}

export default App