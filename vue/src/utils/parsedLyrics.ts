// 歌词行
export interface LyricLine {
    time: number // 歌词对应的时间（毫秒）
    text: string // 歌词文本
    translation?: string // 可选的翻译文本
}

/**
 * 解析歌词
 * @param lrc 歌词
 * @returns 返回歌词数组
 */
export function parseLRC(lrc: string): LyricLine[] {
    const lines = lrc.split('\n')
    const result: LyricLine[] = []
  
    for (const line of lines) {
      const match = line.match(/\[(\d+):(\d+(?:\.\d+)?)\](.*)/)
      if (match) {
        const [, min, sec, rawText] = match
        const time = parseInt(min) * 60 + parseFloat(sec)
  
        // 尝试中英文分离
        const zhIndex = rawText.search(/[\u4e00-\u9fa5]/)
        let text = rawText.trim()
        let translation: string | undefined
  
        if (zhIndex > 0) {
          text = rawText.slice(0, zhIndex).trim()
          translation = rawText.slice(zhIndex).trim()
        }
  
        result.push({ time, text, translation })
      }
    }
  
    return result.sort((a, b) => a.time - b.time)
  }
