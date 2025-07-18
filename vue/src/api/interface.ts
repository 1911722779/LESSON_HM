export interface PlaylistSong {
  songId: number
  songName: string
  artistName: string
  album: string
  duration: string
  coverUrl: string | null
  audioUrl: string
  likeStatus: number
  releaseTime: string | null
}

export interface PlaylistComment {
  commentId: number
  username: string
  userAvatar: string | null
  content: string
  createTime: string
  likeCount: number
  liked: boolean | null
}

// 导出 Song 类型
export interface Song {
  songId: number
  songName: string
  artistName: string
  album: string
  duration: string
  coverUrl: string
  audioUrl: string
  likeStatus: number
  removeStatus: number
  // 新增歌词地址属性
  lyricUrl: string
  releaseTime: string
}

export interface PlaylistComment {
  commentId: number
  username: string
  userAvatar: string | null
  content: string
  createTime: string
  likeCount: number
}

export interface PlaylistDetail {
  playlistId: number
  title: string
  coverUrl: string | null
  introduction: string
  songs: PlaylistSong[]
  likeStatus: number
  comments: PlaylistComment[]
  isCollected: boolean,
  isPrivate: number
  createBy: string,
  createTime: string
}

export interface Comment {
  commentId: number
  username: string
  userAvatar: string | null
  content: string
  createTime: string
  likeCount: number
}

export interface SongDetail {
  songId: number
  songName: string
  artistName: string
  album: string
  lyric: string | null
  duration: string
  coverUrl: string
  audioUrl: string
  releaseTime: string
  likeStatus: boolean | null
  comments: Comment[]
}

// 定义歌手详情类型
export interface ArtistDetail {
  artistId: number
  artistName: string
  gender: number
  avatar: string
  birth: string
  area: string
  introduction: string
  songs: Song[]
}

// 定义推荐歌单结构类型
export interface RecommendedPlay{
  playlistId:number,
  title:string,
  coverUrl:string
}
// 歌手信息实体
export interface Artist{
  //歌手ID
  artistId:number,
  // 歌手名称
  artistName:string,
  // 歌手头像
  avatar:string
}