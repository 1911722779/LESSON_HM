// src/utils/eventBus.ts
import mitt from 'mitt'

// 事件定义
type Events = {
  'play-music': { songId: string }
  'like-music': { songId: string }
  'download-music': { songId: string }
  'show-login-dialog': { show: boolean }
}

export const emitter = mitt<Events>()
