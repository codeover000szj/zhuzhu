import { API_BASE_URL } from '@/config/api'

const heritageImage = (fileName) => `/files/bussiness/heritage_item/${fileName}`
const bilibiliVideo = (bvid) => `https://www.bilibili.com/video/${bvid}/`
const bilibiliSearch = (keyword) => `https://search.bilibili.com/all?keyword=${encodeURIComponent(keyword)}`

const COURSE_MEDIA = [
  {
    keywords: ['苏州评弹'],
    cover: heritageImage('cover_2026_001_suzhou_pingtan.jpg'),
    coverAlt: '苏州评弹演出现场',
    videoUrl: bilibiliVideo('BV1eD421M7LK'),
    videoTitle: '苏州评弹开篇、说表与弹唱'
  },
  {
    keywords: ['端午节民俗', '龙舟'],
    cover: heritageImage('2026_folk_dragon_boat.jpg'),
    coverAlt: '端午龙舟民俗活动',
    videoUrl: bilibiliVideo('BV1Nb411F7h3'),
    videoTitle: '西塞神舟会与端午龙舟文化'
  },
  {
    keywords: ['紫砂'],
    cover: heritageImage('2026_craft_yixing_teapot.jpg'),
    coverAlt: '宜兴紫砂陶壶',
    videoUrl: bilibiliVideo('BV1FPwpe4EVw'),
    videoTitle: '宜兴紫砂陶制作技艺'
  },
  {
    keywords: ['昆曲'],
    cover: heritageImage('2026_opera_kunqu.jpg'),
    coverAlt: '昆曲舞台表演',
    videoUrl: bilibiliVideo('BV1dJ4m1n7PZ'),
    videoTitle: '昆曲身段与水袖表演'
  },
  {
    keywords: ['孔雀舞'],
    cover: heritageImage('2026_dance_peacock.jpg'),
    coverAlt: '杨丽萍孔雀舞演出',
    videoUrl: bilibiliVideo('BV1RSpp62ELz'),
    videoTitle: '孔雀舞形态与节奏教学'
  },
  {
    keywords: ['兰州牛肉面'],
    cover: heritageImage('2026_food_lanzhou_beef_noodles.jpg'),
    coverAlt: '兰州牛肉面',
    videoUrl: bilibiliVideo('BV1g4411273g'),
    videoTitle: '兰州牛肉面拉面技法'
  },
  {
    keywords: ['古琴'],
    cover: heritageImage('2026_music_guqin_performance.jpg'),
    coverAlt: '古琴演奏',
    videoUrl: bilibiliVideo('BV12Z4y1F7hQ'),
    videoTitle: '古琴减字谱与指法教学'
  },
  {
    keywords: ['景德镇青花瓷'],
    cover: heritageImage('1760602376381.jpeg'),
    coverAlt: '景德镇青花瓷器',
    videoUrl: bilibiliVideo('BV1BGA8zqEun'),
    videoTitle: '青花瓷绘画技法'
  },
  {
    keywords: ['潍坊风筝', '传统风筝'],
    cover: heritageImage('2026_craft_weifang_kite.jpg'),
    coverAlt: '潍坊世界风筝博物馆藏品',
    videoUrl: bilibiliSearch('潍坊传统风筝制作技艺'),
    videoTitle: '潍坊传统风筝制作技艺视频'
  },
  {
    keywords: ['西湖绸伞'],
    cover: heritageImage('1760602548983.jpeg'),
    coverAlt: '西湖绸伞工艺',
    videoUrl: bilibiliVideo('BV1tc411M7kf'),
    videoTitle: '西湖绸伞制作工艺'
  },
  {
    keywords: ['蜀绣'],
    cover: heritageImage('1760602505677.jpeg'),
    coverAlt: '蜀绣双面绣作品',
    videoUrl: bilibiliVideo('BV1rfp26ZEZu'),
    videoTitle: '蜀绣晕针技法教学'
  },
  {
    keywords: ['华县皮影'],
    cover: heritageImage('1760602527638.jpeg'),
    coverAlt: '陕西皮影戏舞台表演',
    videoUrl: bilibiliVideo('BV1bx411W76Z'),
    videoTitle: '陕西华县皮影戏'
  },
  {
    keywords: ['苏绣'],
    cover: heritageImage('2026_craft_suzhou_embroidery.jpg'),
    coverAlt: '苏绣作品',
    videoUrl: bilibiliVideo('BV1pE41167ei'),
    videoTitle: '苏绣绣法与针法基础'
  }
]

const ILLUSTRATIVE_AVATAR_SOURCES = [
  '1500648767791-00dcc994a43e',
  '1534528741775-53994a69daeb',
  '1506794778202-cad84cf45f1d',
  '1544005313-94ddf0286df2',
  '1507003211169-0a1dd7228f2d',
  '1438761681033-6461ffad8d80',
  '1524504388940-b1c1722653e1',
  '1494790108377-be9c29b29330'
].map((photoId, index) => ({
  file: `portrait-${String(index + 1).padStart(2, '0')}.jpg`,
  source: `https://images.unsplash.com/photo-${photoId}?auto=format&fit=crop&crop=faces&w=480&h=480&q=82`,
  credit: 'Unsplash photographer',
  license: 'Unsplash License'
}))

function avatarIndex(inheritor) {
  const identity = String(inheritor?.id || inheritor?.name || 'inheritor')
  const hash = Array.from(identity).reduce((value, character) => (
    Math.imul(value, 31) + character.codePointAt(0)
  ) >>> 0, 7)
  return hash % ILLUSTRATIVE_AVATAR_SOURCES.length
}

export function getInheritorFallbackMedia(inheritor) {
  const index = avatarIndex(inheritor)
  const photo = ILLUSTRATIVE_AVATAR_SOURCES[index]

  return {
    src: `/images/inheritor-demo/${photo.file}`,
    source: photo.source,
    credit: photo.credit,
    license: photo.license,
    illustrative: true
  }
}

export function getCourseMedia(title) {
  const courseTitle = String(title || '')
  return COURSE_MEDIA.find((media) => media.keywords.some((keyword) => courseTitle.includes(keyword))) || {
    cover: heritageImage('cover_2026_001_suzhou_pingtan.jpg'),
    coverAlt: courseTitle || '非遗课程',
    videoUrl: courseTitle ? bilibiliSearch(courseTitle) : '',
    videoTitle: courseTitle ? `${courseTitle}相关视频` : ''
  }
}

export function getInheritorMedia(inheritor) {
  if (inheritor?.avatarPath) {
    return { src: inheritor.avatarPath, illustrative: false }
  }

  if (inheritor?.avatarFileId) {
    return {
      src: `${API_BASE_URL}/api/file/preview/${inheritor.avatarFileId}`,
      illustrative: false
    }
  }

  return getInheritorFallbackMedia(inheritor)
}

export function getChapterResearchUrl(courseTitle, chapterTitle) {
  const chapter = String(chapterTitle || '').replace(/^第[一二三四五六七八九十\d]+章[：:、\s]*/, '')
  const query = `site:ihchina.cn ${courseTitle || ''} ${chapter}`.trim()
  return `https://www.google.com/search?q=${encodeURIComponent(query)}`
}

export const MEDIA_SOURCE_NOTES = [
  {
    file: '2026_craft_weifang_kite.jpg',
    source: 'https://commons.wikimedia.org/wiki/File:Kite_museum_weifang_2010_06_06.jpg',
    credit: 'Wikimedia Commons contributor SchiDD',
    license: 'CC BY-SA 3.0',
    note: '潍坊世界风筝博物馆图片，已下载为本地课程封面'
  },
  {
    file: '2026_dance_peacock.jpg',
    source: 'https://commons.wikimedia.org/wiki/File:Yang_liping_01.jpg',
    credit: 'Wikimedia Commons contributor Tutmos',
    license: 'CC BY-SA 4.0'
  },
  {
    file: '2026_craft_yixing_teapot.jpg',
    source: 'https://commons.wikimedia.org/wiki/File:Ceramic_stoneware_teapot_produced_with_Yixing_clay_before_1923_CE_Jiangsu_Province_China.jpg',
    credit: 'Wikimedia Commons contributor Mharrsch',
    license: 'CC BY-SA 4.0'
  },
  {
    file: '2026_music_guqin_performance.jpg',
    source: 'https://commons.wikimedia.org/wiki/File:Wu_Na_with_guqin_01.jpg',
    credit: 'Wikimedia Commons contributor Takeaway',
    license: 'CC BY-SA 3.0'
  },
  ...ILLUSTRATIVE_AVATAR_SOURCES.map((photo) => ({
    file: photo.file,
    source: photo.source,
    credit: photo.credit,
    license: photo.license,
    note: '示意头像，不代表任何传承人本人；Unsplash License 允许使用，无需署名'
  }))
]
