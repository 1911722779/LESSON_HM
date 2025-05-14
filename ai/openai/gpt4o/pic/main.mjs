import dotenv from 'dotenv';
import OpenAI from "openai";
dotenv.config();
console.log(process.env.OpenAI_API_KEY,'////');

// 实例化openai 客户端
const client = new OpenAI({
    apiKey:'sk-newDEG8UhIM78Da5xcPLwsRv0vj83yCVviIxegcYLHlqGFkAe',
    baseURL:'https://api.302.ai/v1' // 做转发
})

// 良好的编程风格
// 主函数 执行的入口，单点
// 下述为函数声明
// function  main () {
//     console.log('ai 全栈开始了 ')
// }

// es6 箭头函数 比传统函数更简洁
// 赋值语句
// js中 函数也是对象
// 下述为函数表达式
// async 是函数修饰符，与 await 是一对
const main = async () => {
    // openai 的调用是异步 
    // await 等一会儿
    // completions 完成问答
    // create 创建
    try{
        const response = await client.chat.completions.create({
            model:'gpt-4o',
            // 对话列表
            messages:[
                {
                    role:'user', // 角色
                    content:[
                        {
                            type:'text',
                            'text':'请描述以下图片的内容'
                        },
                        {
                            type:'image_url',
                            'image_url':{
                                "url":'https://tr-osdcp.qunarzz.com/tr-osd-tr-space/img/c0738cb7051a67536eb16bb2aa553c6c.jpg_r_1360x1360x95_cd4a9d92.jpg'
                            }
    
                        }
                    ]
                }
            ],
            max_tokens:300
        })
        // console.log(response);
        console.log(response.choices[0].message.content);
    } catch(err){
        console.log(err);
    }
    
}

// main()