<template>
  <div
    class="heritage-home"
    :class="{ 'hero-is-paused': heroPaused }"
  >
    <section
      ref="heroSection"
      class="heritage-hero"
      data-snap-section
      aria-label="非遗影像专题"
      aria-roledescription="轮播图"
    >
      <Transition name="scene-fade">
        <img
          :key="activeSlide"
          class="hero-still"
          :src="heroSlides[activeSlide].image"
          :alt="heroSlides[activeSlide].alt"
        >
      </Transition>
      <video
        v-if="heroSlides[activeSlide].video"
        ref="heroVideo"
        class="hero-video"
        :autoplay="heroCanPlay"
        muted
        playsinline
        preload="metadata"
        poster="/images/hero-poster.jpg"
        aria-label="中国传统制茶技艺及其相关习俗影像"
        @ended="advanceHero"
      >
        <source
          src="/media/heritage-opening.mp4"
          type="video/mp4"
        >
      </video>
      <div class="hero-shade" />
      <div
        :key="activeSlide"
        class="hero-caption"
      >
        <span class="hero-caption-kicker">{{ heroSlides[activeSlide].eyebrow }}</span>
        <h1>{{ heroSlides[activeSlide].title }}</h1>
        <p>{{ heroSlides[activeSlide].subtitle }}</p>
      </div>
      <div class="hero-controls">
        <div class="hero-slide-meta">
          <span>影像专题</span><i /><span>0{{ activeSlide + 1 }} / 0{{ heroSlides.length }}</span>
        </div>
        <div
          class="hero-slide-markers"
          role="tablist"
          aria-label="选择首页影像专题"
        >
          <button
            v-for="(slide, index) in heroSlides"
            :key="slide.title"
            type="button"
            role="tab"
            :aria-label="`第${index + 1}个专题：${slide.title}`"
            :aria-selected="activeSlide === index"
            :tabindex="activeSlide === index ? 0 : -1"
            :class="{ active: activeSlide === index }"
            @click="selectSlide(index)"
            @keydown="handleSlideKeydown($event, index)"
          >
            <HeritageKnot />
          </button>
        </div>
        <div class="hero-control-actions">
          <button
            type="button"
            class="hero-previous"
            aria-label="上一个非遗专题"
            @click="selectSlide(activeSlide - 1)"
          >
            <ArrowLeftOutlined />
          </button>
          <button
            type="button"
            class="hero-next"
            aria-label="下一个非遗专题"
            @click="selectSlide(activeSlide + 1)"
          >
            <ArrowRightOutlined />
          </button>
          <button
            type="button"
            class="hero-play"
            :aria-label="heroPaused ? '继续自动轮播' : '暂停自动轮播'"
            :aria-pressed="heroPaused"
            @click="toggleHero"
          >
            <PauseOutlined v-if="!heroPaused" /><CaretRightOutlined v-else />
          </button>
          <button
            type="button"
            class="hero-down"
            aria-label="向下浏览"
            @click="scrollToPortal"
          >
            <ArrowDownOutlined />
          </button>
        </div>
      </div>
      <span class="hero-side-note">传承有序 · 生生不息</span>
    </section>

    <div
      id="portal-content"
      class="home-content"
      data-snap-content
    >
      <nav
        class="portal-quick-links"
        data-snap-section
        aria-label="非遗门类快捷入口"
      >
        <div class="quick-links-heading">
          <span class="section-eyebrow">DISCOVER THE LIVING HERITAGE</span><strong>循门类而入</strong>
        </div>
        <button
          v-for="category in categoryLinks.slice(0, 6)"
          :key="category.name"
          type="button"
          class="quick-category"
          @click="viewCategory(category.name)"
        >
          <span>{{ category.glyph }}</span><strong>{{ category.name }}</strong><small>{{ category.note }}</small><ArrowRightOutlined />
        </button>
        <button
          class="quick-more"
          type="button"
          @click="viewAllItems"
        >
          全部门类 <ArrowRightOutlined />
        </button>
      </nav>

      <section class="portal-bulletin" data-snap-section>
        <div class="bulletin-label">
          <span class="bulletin-seal"><HeritageKnot /></span><span><b>传习<br>简报</b><small>FIELD NOTES</small></span>
        </div>
        <div class="bulletin-items">
          <button
            v-for="(item, index) in bulletinItems"
            :key="item.label"
            type="button"
            class="bulletin-item"
            @click="item.action"
          >
            <small>0{{ index + 1 }} / {{ item.kind }}</small><strong>{{ item.label }}</strong><span>{{ item.description }}</span>
          </button>
        </div>
      </section>

      <section class="portal-intro" data-snap-section>
        <div class="intro-lead">
          <span class="section-eyebrow">CULTURE IN EVERYDAY LIFE</span><h2>见人 · 见物 · 见生活</h2>
        </div>
        <p>这里是面向公众的非遗数字档案与传习空间。我们以作品为线索，连接传承人、课程、活动与共学讨论，让每一次浏览都能继续成为一次学习、记录与交流。</p>
        <div class="intro-stats">
          <div><strong>01</strong><span>作品档案</span></div><div><strong>02</strong><span>传承人物</span></div><div><strong>03</strong><span>在线传习</span></div>
        </div>
      </section>

      <HeritageChinaMap data-snap-section />

      <!-- 2. 精选作品 -->
      <section class="featured-items" data-snap-section>
        <div class="section-header">
          <div class="section-heading">
            <span class="section-eyebrow">THE DIGITAL COLLECTION</span>
            <h2 class="section-title">
              作品 · 典藏
            </h2>
          </div><span class="section-divider" />
          <a-button
            type="link"
            @click="viewAllItems"
          >
            查看更多 <ArrowRightOutlined />
          </a-button>
        </div>

        <PortalSpotlightCarousel
          v-if="collectionSlides.length"
          :slides="collectionSlides"
          label="作品典藏精选"
        />
      </section>

      <!-- 4. 传承人风采 - 圆形头像墙 -->
      <section class="inheritor-showcase" data-snap-section>
        <div class="section-header">
          <div class="section-heading">
            <span class="section-eyebrow">THE PEOPLE BEHIND THE CRAFT</span>
            <h2 class="section-title">
              人物 · 匠心
            </h2>
          </div><span class="section-divider" />
          <a-button
            type="link"
            @click="viewAllInheritors"
          >
            查看更多 <ArrowRightOutlined />
          </a-button>
        </div>

        <div class="inheritor-wall">
          <div 
            v-for="inheritor in inheritors" 
            :key="inheritor.id"
            class="inheritor-avatar-card"
            role="link"
            tabindex="0"
            @click="viewInheritorDetail(inheritor.id)"
            @keydown.enter="viewInheritorDetail(inheritor.id)"
          >
            <div class="avatar-container">
              <div class="avatar-border">
                <img 
                  :src="getInheritorAvatarUrl(inheritor)" 
                  :alt="`${inheritor.name || '传承人'}头像`"
                  class="avatar-image"
                  @error="handleInheritorAvatarError($event, inheritor)"
                >
              </div>
              <div class="avatar-title-badge">
                {{ inheritor.title }}
              </div>
            </div>
            <h4 class="inheritor-name">
              {{ inheritor.name }}
            </h4>
            <p class="inheritor-region">
              {{ inheritor.region }}
            </p>
            <p class="inheritor-excerpt">
              {{ plainText(inheritor.bio).slice(0, 76) }}
            </p>
            <span class="inheritor-link">走近传承人 <ArrowRightOutlined /></span>
          </div>
        </div>
      </section>

      <!-- 5. 近期活动 - 时间轴式展示 -->
      <section class="upcoming-activities" data-snap-section>
        <div class="section-header">
          <div class="section-heading">
            <span class="section-eyebrow">HERITAGE IN THE PRESENT</span>
            <h2 class="section-title">
              活动 · 现场
            </h2>
          </div><span class="section-divider" />
          <a-button
            type="link"
            @click="viewAllActivities"
          >
            查看更多 <ArrowRightOutlined />
          </a-button>
        </div>

        <div class="activity-timeline">
          <div 
            v-for="(activity, index) in activities" 
            :key="activity.id"
            class="activity-node"
            :class="{ 'node-alternate': index % 2 === 1 }"
          >
            <div class="timeline-dot">
              <div class="dot-inner" />
            </div>
            <div
              class="activity-card"
              role="link"
              tabindex="0"
              @click="viewActivityDetail(activity.id)"
              @keydown.enter="viewActivityDetail(activity.id)"
            >
              <div class="activity-cover">
                <img
                  :src="getActivityCoverUrl(activity)"
                  :alt="activity.title"
                >
              </div>
              <div class="activity-info">
                <div class="activity-time">
                  <CalendarOutlined />
                  {{ formatDate(activity.startTime) }}
                </div>
                <h4 class="activity-title">
                  {{ activity.title }}
                </h4>
                <div class="activity-meta">
                  <a-tag :color="getActivityTypeColor(activity.type)">
                    {{ activity.type }}
                  </a-tag>
                  <span class="activity-location">
                    <EnvironmentOutlined />
                    {{ activity.location }}
                  </span>
                </div>
                <p class="activity-desc">
                  {{ plainText(activity.description).slice(0, 100) }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 6. 在线课程 - 书架式布局 -->
      <section class="online-courses" data-snap-section>
        <div class="section-header">
          <div class="section-heading">
            <span class="section-eyebrow">LEARN A CRAFT, KEEP IT ALIVE</span>
            <h2 class="section-title">
              课堂 · 传习
            </h2>
          </div><span class="section-divider" />
          <a-button
            type="link"
            @click="viewAllCourses"
          >
            查看更多 <ArrowRightOutlined />
          </a-button>
        </div>

        <div class="bookshelf">
          <div class="shelf-row">
            <div 
              v-for="course in courses" 
              :key="course.id"
              class="book-spine"
              role="link"
              tabindex="0"
              @click="viewCourseDetail(course.id)"
              @keydown.enter="viewCourseDetail(course.id)"
            >
              <div class="book-cover">
                <img
                  :src="getCourseMedia(course.title).cover"
                  :alt="getCourseMedia(course.title).coverAlt"
                  loading="lazy"
                >
                <span class="course-play"><CaretRightOutlined /></span>
              </div>
              <div class="book-content">
                <h4 class="book-title">
                  {{ course.title }}
                </h4>
                <div class="book-level">
                  {{ getLevelText(course.level) }}
                </div>
                <p class="course-excerpt">
                  <span v-if="course.chapterCount">{{ course.chapterCount }} 个学习章节 · </span>图文资料与视频学习
                </p>
                <span class="course-entry">进入课堂 <ArrowRightOutlined /></span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="category-atlas" data-snap-section>
        <div class="atlas-heading">
          <HeritageKnot /><h2>循门类，识非遗</h2><p>流传于世<br>生息于人</p><HeritageKnot />
        </div>
        <div class="category-grid">
          <button
            v-for="(category, index) in categoryLinks"
            :key="category.name"
            class="category-tile"
            @click="viewCategory(category.name)"
          >
            <span class="category-number">0{{ index + 1 }}</span><span class="category-glyph">{{ category.glyph }}</span><span class="category-name">{{ category.name }}</span><span class="category-count">{{ category.note }}</span><span class="category-arrow">↗</span>
          </button>
        </div>
      </section>

      <section class="community-invitation" data-snap-section>
        <div>
          <span class="section-eyebrow">KEEP THE CONVERSATION GOING</span><h2>一门技艺的传承<br>从一次交流开始</h2><p>把学习里的疑问、手作中的发现，带进共学的讨论。<br>与传承人、老师和同好一起，让技艺在实践中继续生长。</p><router-link to="/community">
            进入共学论坛 <ArrowRightOutlined />
          </router-link>
        </div><div class="invitation-mark">
          <HeritageKnot /><span>共学<br>共传</span>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { 
  ArrowLeftOutlined,
  ArrowRightOutlined,
  EnvironmentOutlined,
  CalendarOutlined,
  PauseOutlined,
  CaretRightOutlined,
  ArrowDownOutlined
} from '@ant-design/icons-vue'
import HeritageKnot from '@/components/frontend/HeritageKnot.vue'
import HeritageChinaMap from '@/components/frontend/HeritageChinaMap.vue'
import PortalSpotlightCarousel from '@/components/frontend/PortalSpotlightCarousel.vue'
import { getHeritageItemPage } from '@/api/HeritageApi'
import { getInheritorPage } from '@/api/InheritorApi'
import { getActivityPage } from '@/api/ActivityApi'
import { getCoursePage } from '@/api/CourseApi'
import { API_BASE_URL } from '@/config/api'
import { getCourseMedia, getInheritorMedia, getInheritorFallbackMedia } from '@/config/heritageMedia'
import { withDisplayYear } from '@/utils/dateUtils'

const router = useRouter()

const enableHomeSnap = () => {
  document.documentElement.classList.add('home-snap-page')
}

const disableHomeSnap = () => {
  document.documentElement.classList.remove('home-snap-page')
}

// 数据
const featuredItems = ref([])
const collectionSlides = computed(() => featuredItems.value.map(item => ({
  id: item.id, title: item.title, image: getItemCoverUrl(item), alt: item.title,
  description: plainText(item.description || item.summary), tag: item.category,
  meta: item.region, to: `/heritage/${item.id}`
})))
const inheritors = ref([])
const activities = ref([])
const courses = ref([])
const activeSlide = ref(0)
const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)')
const heroPaused = ref(reducedMotion.matches)
const heroVideo = ref(null)
const heroSection = ref(null)
const heroInView = ref(true)
const pageVisible = ref(document.visibilityState === 'visible')
const heroCanPlay = computed(() => !heroPaused.value && heroInView.value && pageVisible.value)
let heroObserver
let slideTimer
let heroDisposed = false
let slideRevision = 0
const heroSlides = [
  { eyebrow: '非遗影像 · 中国传统制茶技艺及其相关习俗', title: '一叶千年，山水之间有传承', subtitle: '循着一缕茶香，走进人与自然相知相依的生活。', image: '/images/hero-poster.jpg', alt: '山岩与云雾间的绿色梯田茶园', video: true },
  { eyebrow: '非遗封面 · 苏绣', title: '一针一线，绣出江南风华', subtitle: '以丝为笔，以针为墨，在方寸绢帛间留下细腻的东方意境。', image: '/files/bussiness/heritage_item/2026_craft_suzhou_embroidery.jpg', alt: '苏绣传统刺绣艺术作品' },
  { eyebrow: '非遗封面 · 昆曲', title: '水磨清音，一曲六百年', subtitle: '听婉转唱腔，看水袖流转，让古老戏台与今天的心灵相逢。', image: '/files/bussiness/heritage_item/2026_opera_kunqu.jpg', alt: '身着传统戏服的昆曲舞台表演' },
  { eyebrow: '非遗封面 · 苗族歌舞', title: '山水有回响，歌舞寄深情', subtitle: '银饰、盛装与悠扬歌声，共同讲述村寨里代代相传的生活记忆。', image: '/files/bussiness/heritage_item/2026_dance_miao_festival.jpg', alt: '身着苗族传统服饰的人们参加节庆歌舞' },
  { eyebrow: '非遗封面 · 潍坊风筝', title: '借一缕长风，放飞匠心', subtitle: '扎骨、糊面、绘彩、放飞，一线牵起民间美术与天空的浪漫。', image: '/files/bussiness/heritage_item/2026_craft_weifang_kite.jpg', alt: '潍坊传统风筝的彩绘造型' }
]
const categoryLinks = [
  { name: '民间文学', glyph: '文', note: '故事与口述记忆' },
  { name: '传统音乐', glyph: '音', note: '乡音与古调' },
  { name: '传统舞蹈', glyph: '舞', note: '身体里的节奏' },
  { name: '传统戏剧', glyph: '戏', note: '台前幕后皆有戏' },
  { name: '传统美术', glyph: '艺', note: '形色之间见匠心' },
  { name: '传统技艺', glyph: '工', note: '手作中的时间' },
  { name: '传统医药', glyph: '药', note: '经验与生活智慧' },
  { name: '民俗礼仪', glyph: '俗', note: '岁时与人间烟火' }
]
const bulletinItems = [
  { kind: '档案', label: '作品档案', description: '循着门类，走近作品与地方记忆', action: () => router.push('/heritage') },
  { kind: '传习', label: '在线课堂', description: '从基础知识到工序细节，按章学习', action: () => router.push('/course') },
  { kind: '共学', label: '共学答疑', description: '把问题带到传承现场，与大家继续讨论', action: () => router.push('/community') }
]

const loadHomeSections = async () => {
  const requests = await Promise.allSettled([
    getHeritageItemPage({ current: 1, size: 4, status: 2 }, { showDefaultMsg: false }),
    getInheritorPage({ current: 1, size: 4 }, { showDefaultMsg: false }),
    getActivityPage({ current: 1, size: 4 }, { showDefaultMsg: false }),
    getCoursePage({ current: 1, size: 4, status: 1 }, { showDefaultMsg: false })
  ])
  const assignRecords = (result, target, label) => {
    if (result.status === 'fulfilled') target.value = result.value?.records || []
    else console.warn(`${label}加载失败:`, result.reason)
  }
  assignRecords(requests[0], featuredItems, '作品档案')
  assignRecords(requests[1], inheritors, '传承人')
  assignRecords(requests[2], activities, '近期活动')
  assignRecords(requests[3], courses, '在线课程')
}

const startSlideTimer = () => {
  clearTimeout(slideTimer)
  if (heroDisposed || !heroCanPlay.value) return
  slideTimer = window.setTimeout(() => {
    advanceHero()
  }, heroSlides[activeSlide.value].video ? 24000 : 8000)
}
const syncHeroPlayback = () => {
  if (heroDisposed) return
  if (heroCanPlay.value && heroSlides[activeSlide.value].video) heroVideo.value?.play().catch(() => {})
  else heroVideo.value?.pause()
  startSlideTimer()
}
const handlePageVisibility = () => {
  pageVisible.value = document.visibilityState === 'visible'
  syncHeroPlayback()
}
const selectSlide = async (index) => {
  if (heroDisposed) return
  const revision = ++slideRevision
  clearTimeout(slideTimer)
  heroVideo.value?.pause()
  activeSlide.value = (index + heroSlides.length) % heroSlides.length
  await nextTick()
  if (!heroDisposed && revision === slideRevision) syncHeroPlayback()
}
const advanceHero = () => {
  if (heroCanPlay.value && !heroDisposed) selectSlide(activeSlide.value + 1)
}
const handleSlideKeydown = async (event, index) => {
  const targets = { ArrowLeft: index - 1, ArrowRight: index + 1, Home: 0, End: heroSlides.length - 1 }
  if (!(event.key in targets)) return
  event.preventDefault()
  const markers = event.currentTarget.parentElement
  await selectSlide(targets[event.key])
  if (!heroDisposed) markers?.querySelector('[aria-selected="true"]')?.focus()
}
const handleMotionPreference = (event) => {
  heroPaused.value = event.matches
  syncHeroPlayback()
}
const toggleHero = () => {
  heroPaused.value = !heroPaused.value
  syncHeroPlayback()
}
const scrollToPortal = () => document.getElementById('portal-content')?.scrollIntoView({ behavior: 'smooth' })

onMounted(() => {
  enableHomeSnap()
  loadHomeSections()
  document.addEventListener('visibilitychange', handlePageVisibility)
  reducedMotion.addEventListener('change', handleMotionPreference)
  if (window.IntersectionObserver && heroSection.value) {
    heroObserver = new IntersectionObserver(([entry]) => {
      heroInView.value = entry.isIntersecting
      syncHeroPlayback()
    }, { threshold: 0.01 })
    heroObserver.observe(heroSection.value)
  }
  syncHeroPlayback()
})
onUnmounted(() => {
  disableHomeSnap()
  heroDisposed = true
  clearTimeout(slideTimer)
  heroObserver?.disconnect()
  document.removeEventListener('visibilitychange', handlePageVisibility)
  reducedMotion.removeEventListener('change', handleMotionPreference)
  heroVideo.value?.pause()
})

// 工具函数
const getItemCoverUrl = (item) => {
  // 优先使用 coverImage（完整路径）
  if (item.coverImage) {
    return item.coverImage
  }
  // 其次使用 coverFileId
  if (item.coverFileId) {
    return `${API_BASE_URL}/file/preview/${item.coverFileId}`
  }
  // 默认占位图
  return '/images/portal-textile.jpg'
}

const getInheritorAvatarUrl = (inheritor) => {
  return getInheritorMedia(inheritor)?.src || '/api/placeholder/160/160'
}

const handleInheritorAvatarError = (event, inheritor) => {
  const image = event.currentTarget
  image.onerror = null
  image.src = getInheritorFallbackMedia(inheritor).src
}

const getActivityCoverUrl = (activity) => {
  // 优先使用 coverFilePath（完整路径）
  if (activity.coverFilePath) {
    return activity.coverFilePath
  }
  // 其次使用 coverFileId
  if (activity.coverFileId) {
    return `${API_BASE_URL}/file/preview/${activity.coverFileId}`
  }
  return '/images/activity-placeholder.svg'
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = withDisplayYear(dateStr)
  return date ? `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日` : ''
}
const plainText = (value) => String(value || '').replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim()

const getLevelText = (level) => {
  const map = {
    'beginner': '入门',
    'elementary': '初级',
    'intermediate': '中级',
    'advanced': '高级'
  }
  return map[level] || '入门'
}

const getActivityTypeColor = (type) => {
  const colorMap = {
    '展演': 'blue',
    '展览': 'green',
    '培训': 'orange',
    '比赛': 'red'
  }
  return colorMap[type] || 'default'
}

// 导航函数
const viewAllItems = () => router.push('/heritage')
const viewCategory = (category) => router.push({ path: '/heritage', query: { category } })
const viewAllInheritors = () => router.push('/inheritor')
const viewInheritorDetail = (id) => router.push(`/inheritor/${id}`)
const viewAllActivities = () => router.push('/activity')
const viewActivityDetail = (id) => router.push(`/activity/${id}`)
const viewAllCourses = () => router.push('/course')
const viewCourseDetail = (id) => router.push(`/course/${id}`)
</script>

<style scoped>
.heritage-home { --ink: #302e28; --muted: #8c857a; --red: #a32b23; --gold: #b9a17b; --paper: #f7f4ec; color: var(--ink); background: var(--paper); font-family: 'Songti SC', 'STSong', 'SimSun', serif; overflow-x: clip; }
.heritage-home button, .heritage-home a { -webkit-tap-highlight-color: transparent; }
.heritage-home button:focus-visible, .heritage-home a:focus-visible, .heritage-home [role="link"]:focus-visible { outline: 2px solid var(--red); outline-offset: 5px; }
:global(.home-snap-page) { scroll-snap-type: y proximity; scroll-behavior: smooth; }
:global(.home-snap-page) [data-snap-section] { scroll-snap-align: start; scroll-snap-stop: normal; }
:global(.home-snap-page) .heritage-hero { scroll-snap-align: start; scroll-margin-top: 0; }
:global(.home-snap-page) [data-snap-section] { position: relative; }
.heritage-hero { position: relative; height: 100svh; min-height: 670px; max-height: 1300px; isolation: isolate; color: #fff; overflow: hidden; background: #283c37; }
.hero-still, .hero-video { position: absolute; width: 100%; height: 100%; inset: 0; object-fit: cover; z-index: -3; }
.hero-still { animation: image-drift 16s ease-out both; }
.hero-video { z-index: -2; }
.hero-shade { position: absolute; inset: 0; z-index: -1; background: linear-gradient(180deg, #10201b22 28%, transparent 44%, #13201a8c 100%), linear-gradient(90deg,#12231e2b,transparent 80%); }
.hero-caption { position: absolute; bottom: 19%; left: 8.3%; max-width: 700px; text-shadow: 0 2px 25px #18231dcc; animation: caption-enter 1.1s both; }
.hero-caption-kicker { display: inline-block; margin-bottom: 22px; border-left: 2px solid #b52e27; padding-left: 13px; font-size: 13px; letter-spacing: .25em; }
.hero-caption h1 { margin: 0 0 16px; color: #fff; font-size: clamp(28px,3vw,48px); line-height: 1.5; font-weight: 400; letter-spacing: .15em; }
.hero-caption p { margin: 0; font: 13px/2 'PingFang SC', 'Microsoft YaHei', sans-serif; color: #ffffffd9; letter-spacing: .12em; }
.hero-side-note { position: absolute; right: 4%; top: 45%; writing-mode: vertical-rl; font-size: 12px; letter-spacing: .42em; color: #ffffffc9; }
.hero-controls { position: absolute; bottom: 50px; left: 5.2%; right: 5.2%; display: flex; align-items: center; justify-content: space-between; }
.hero-slide-meta { display: flex; align-items: center; gap: 18px; font-size: 11px; letter-spacing: .15em; opacity: .85; }
.hero-slide-meta i { width: 38px; height: 1px; background: #ffffff70; }
.hero-slide-markers { display: flex; position: absolute; left: 50%; transform: translateX(-50%); gap: 22px; }
.hero-slide-markers button { border: 0; padding: 3px; width: 32px; height: 32px; color: #fff; background: transparent; cursor: pointer; transition: color .3s, transform .3s; }
.hero-slide-markers button.active, .hero-slide-markers button:hover { color: #cf4136; transform: scale(1.12); }
.hero-control-actions { display: flex; align-items: center; gap: 24px; }.hero-control-actions button { display: grid; place-items: center; color: #fff; background: transparent; border: 1px solid #ffffff50; border-radius: 50%; width: 36px; height: 36px; font-size: 13px; cursor: pointer; }.hero-down { animation: down-nudge 3s infinite; }
.hero-control-actions button { position: relative; transition: background-color .3s, border-color .3s, box-shadow .3s, transform .3s; }
.hero-control-actions button:hover { background: #a32b23c9; border-color: #edd2a5; box-shadow: 0 0 0 5px #ffffff0c; }
.hero-control-actions button:active { transform: scale(.92); }
.hero-control-actions button:focus-visible, .hero-slide-markers button:focus-visible { outline-color: #fff0d7; }
.hero-play[aria-pressed="true"] { background: #ffffff1f; border-color: #ffffff9c; }
.home-content { position: relative; background-color: var(--paper); background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='160' height='160' viewBox='0 0 160 160'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='.035'/%3E%3C/svg%3E"); }
.section-eyebrow { display: block; color: #a68b65; font: 10px/1.8 Arial,sans-serif; letter-spacing: .18em; }
.portal-quick-links { max-width: 1440px; margin: 0 auto; padding: 45px 42px; display: flex; align-items: center; gap: 0; border-bottom: 1px solid #d7cfc0; }
.quick-links-heading { flex: 0 0 210px; padding-right: 20px; }.quick-links-heading .section-eyebrow { font-size: 8px; letter-spacing: .1em; }.quick-links-heading strong { display: block; margin-top: 8px; font-size: 23px; font-weight: 400; letter-spacing: .12em; }
.quick-category { position: relative; display: flex; flex: 1; flex-direction: column; align-items: center; padding: 0 18px; border: 0; border-left: 1px solid #dcd4c5; background: none; color: inherit; cursor: pointer; transition: color .2s; }.quick-category>span:first-child { display: grid; width: 35px; height: 35px; place-items: center; border: 1px solid #baab92; border-radius: 50%; color: #8c6143; font-size: 19px; }.quick-category strong { font-size: 14px; font-weight: 500; margin: 10px 0 3px; white-space: nowrap; letter-spacing: .1em; }.quick-category small { display: none; }.quick-category>.anticon { display: none; }.quick-category:hover { color: var(--red); }.quick-more { border: 0; background: none; color: #8f342a; font-size: 11px; writing-mode: vertical-rl; letter-spacing: .15em; cursor: pointer; margin-left: 20px; }.quick-more .anticon { margin-top: 10px; }
.portal-bulletin { width: min(1356px,calc(100% - 96px)); margin: 46px auto 0; padding: 26px 0 28px; display: grid; grid-template-columns: 190px 1fr; border: 1px solid #cec1a9; border-left: 3px solid var(--red); background: #ffffff30; }
.bulletin-label { display: flex; align-items: center; gap: 17px; padding: 0 25px; border-right: 1px solid #d8ccb8; }.bulletin-seal { color: var(--red); width: 36px; }.bulletin-label b { font-size: 20px; font-weight: 400; line-height: 1.5; letter-spacing: .17em; }.bulletin-label small { display: block; font: 8px Arial,sans-serif; letter-spacing: .1em; color: #a08d74; margin-top: 7px; white-space: nowrap; }
.bulletin-items { display: grid; grid-template-columns: repeat(3,1fr); }.bulletin-item { padding: 0 30px; text-align: left; background: none; border: 0; border-right: 1px solid #e3d9c9; cursor: pointer; }.bulletin-item:last-child { border: 0; }.bulletin-item small { display: block; font-size: 10px; color: #a48662; letter-spacing: .1em; }.bulletin-item strong { display: block; font-size: 18px; font-weight: 400; margin: 9px 0 5px; letter-spacing: .1em; color: var(--ink); }.bulletin-item span { font: 11px/1.8 'PingFang SC',sans-serif; color: var(--muted); }.bulletin-item:hover strong { color: var(--red); }
.portal-intro { display: flex; align-items: center; justify-content: space-between; gap: 45px; width: min(1356px,calc(100% - 96px)); margin: 0 auto; padding: 74px 0 10px; }.intro-lead { flex-shrink: 0; }.intro-lead h2 { font-size: 27px; margin: 13px 0 0; font-weight: 400; letter-spacing: .1em; }.portal-intro>p { max-width: 580px; margin: 5px 0 0; font: 13px/2.1 'PingFang SC',sans-serif; color: #8b8376; }.intro-stats { display: none; }
.featured-items, .inheritor-showcase, .upcoming-activities, .online-courses { width: min(1356px,calc(100% - 96px)); margin: 0 auto; padding: 78px 0; }
.section-header { display: flex; align-items: center; gap: 32px; margin-bottom: 36px; }.section-heading { flex-shrink: 0; }.section-title { font-size: 31px; font-weight: 400; letter-spacing: .18em; line-height: 1.5; margin: 9px 0 0; }.section-divider { flex: 1; height: 1px; margin-top: 26px; background: #d6ccbb; position: relative; }.section-divider:before { content: ''; position: absolute; left: 0; top: -3px; width: 6px; height: 6px; border: 1px solid #a99472; transform: rotate(45deg); background: var(--paper); }.section-header :deep(.ant-btn-link) { flex-shrink: 0; color: #76634b; font-family: inherit; padding: 0; font-size: 12px; margin-top: 25px; }.section-header :deep(.ant-btn-link .anticon) { margin-left: 18px; }
.items-grid { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 26px; }.item-card { position: relative; cursor: pointer; transition: transform .4s; padding-bottom: 23px; border-bottom: 1px solid #cfc3af; }.item-card:hover { transform: translateY(-5px); }.item-card:hover .item-image img { transform: scale(1.055); }.item-image { height: 235px; overflow: hidden; position: relative; background: #e7e1d6; }.item-image img { width: 100%; height: 100%; object-fit: cover; transition: transform .7s; }.item-category-tag { position: absolute; top: 12px; left: 12px; color: #fff; padding: 7px 10px; background: #8c322aeb; font-size: 11px; writing-mode: vertical-rl; letter-spacing: .2em; }.item-content { padding: 21px 0 0; }.item-title { margin: 0 0 10px; font-size: 19px; line-height: 1.6; font-weight: 500; color: #3b352c; }.item-region { font: 11px 'PingFang SC',sans-serif; color: #a08e73; margin-bottom: 12px; }.item-summary { margin: 0; color: #8e8679; font: 12px/1.9 'PingFang SC',sans-serif; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.inheritor-showcase { position: relative; isolation: isolate; padding-top: 68px; padding-bottom: 70px; }.inheritor-showcase:before { content: ''; position: absolute; left: calc((100vw - 100%)/-2); right: calc((100vw - 100%)/-2); inset-block: 0; background: #eae5d9 url('/images/heritage-detail.jpg') center / cover; background-blend-mode: multiply; z-index: -1; }.inheritor-wall { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 38px; }.inheritor-avatar-card { padding: 10px 26px 0; text-align: center; cursor: pointer; border-right: 1px solid #cfc5b3; }.inheritor-avatar-card:last-child { border-right: 0; }.avatar-container { position: relative; margin-bottom: 24px; }.avatar-border { width: 156px; height: 156px; margin: 0 auto; padding: 7px; border: 1px solid #b6a78e; border-radius: 50%; transition: border-color .3s, transform .4s; }.avatar-image { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; filter: saturate(.75); }.avatar-title-badge { display: inline-block; background: #eee9df; position: relative; margin-top: -13px; padding: 3px 9px; color: #9b4737; border: 1px solid #c5bba7; max-width: 100%; font-size: 10px; }.inheritor-name { margin: 0 0 7px; font-size: 22px; letter-spacing: .15em; font-weight: 400; }.inheritor-region { font: 11px 'PingFang SC',sans-serif; color: #9a8d79; }.inheritor-excerpt { margin: 17px 0 21px; font: 12px/2 'PingFang SC',sans-serif; color: #898173; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }.inheritor-link { color: #826a4b; font-size: 11px; }.inheritor-link .anticon { margin-left: 15px; }.inheritor-avatar-card:hover .avatar-border { border-color: var(--red); transform: translateY(-3px); }
.activity-timeline { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 28px 38px; }.timeline-dot { display: none; }.activity-card { display: flex; gap: 24px; padding-bottom: 25px; border-bottom: 1px solid #d6cbb9; cursor: pointer; }.activity-cover { width: 180px; height: 145px; flex-shrink: 0; overflow: hidden; }.activity-cover img { width: 100%; height: 100%; object-fit: cover; transition: transform .6s; }.activity-card:hover .activity-cover img { transform: scale(1.06); }.activity-info { padding: 2px 0; min-width: 0; }.activity-time { color: #9e8060; font: 10px 'PingFang SC',sans-serif; letter-spacing: .04em; }.activity-title { margin: 12px 0 9px; font-size: 18px; line-height: 1.5; font-weight: 500; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }.activity-meta { display: flex; align-items: center; gap: 5px; }.activity-meta :deep(.ant-tag) { border-radius: 0; color: #927852; background: transparent; border-color: #cbbca4; font-size: 10px; line-height: 18px; }.activity-location { font: 10px/1.5 'PingFang SC',sans-serif; color: #a09480; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }.activity-desc { margin: 12px 0 0; color: #8d8579; font: 11px/1.8 'PingFang SC',sans-serif; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.online-courses { padding-top: 10px; }.shelf-row { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 26px; }.book-spine { border: 1px solid #d7cebd; cursor: pointer; background: #fcfaf4; transition: transform .35s, box-shadow .35s; }.book-spine:hover { transform: translateY(-6px); box-shadow: 0 10px 20px #5d4f3b12; }.book-cover { position: relative; height: 200px; overflow: hidden; background: #e9e2d4; }.book-cover:after { content: ''; position: absolute; inset: 0; background: linear-gradient(0deg,#1f1a173d,transparent 60%); }.book-cover img { width: 100%; height: 100%; object-fit: cover; transition: transform .7s; }.book-spine:hover img { transform: scale(1.05); }.course-play { position: absolute; inset: 0; margin: auto; width: 40px; height: 40px; border: 1px solid #ffffffaa; color: white; display: grid; place-items: center; border-radius: 50%; background: #29231d33; z-index: 1; }.book-content { padding: 21px; position: relative; }.book-title { margin: 0 0 13px; padding-right: 23px; font-size: 17px; font-weight: 500; line-height: 1.6; min-height: 54px; }.book-level { position: absolute; top: 22px; right: 16px; color: #9b4b3c; font-size: 9px; border: 1px solid #c3a18c; writing-mode: vertical-rl; padding: 5px 3px; letter-spacing: .2em; }.course-excerpt { margin: 0 0 20px; color: #9a9082; font: 11px/1.9 'PingFang SC',sans-serif; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }.course-entry { padding-top: 13px; border-top: 1px solid #e7decd; display: flex; align-items: center; justify-content: space-between; color: #806a4c; font-size: 11px; }
.category-atlas { display: flex; min-height: 410px; background: #2d3934; color: #f6f0e3; }.atlas-heading { flex: 0 0 240px; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 22px; position: relative; background: linear-gradient(#17292555,#17292555),repeating-linear-gradient(90deg,#ffffff03 0 1px,transparent 1px 3px); }.atlas-heading>svg { width: 22px; height: 22px; color: #c5b59b; }.atlas-heading h2 { writing-mode: vertical-rl; margin: 22px 0 16px; color: #f4efdf; font-weight: 400; font-size: 25px; letter-spacing: .16em; }.atlas-heading p { display: none; }.category-grid { flex: 1; display: grid; grid-template-columns: repeat(8,1fr); }.category-tile { display: flex; position: relative; flex-direction: column; align-items: center; justify-content: center; padding: 32px 14px; border: 0; color: #f8f0de; background-color: #4d5650; background-image: repeating-linear-gradient(90deg,#ffffff05 0 1px,transparent 1px 3px),repeating-linear-gradient(0deg,#00000007 0 1px,transparent 1px 3px); cursor: pointer; transition: filter .3s, padding-bottom .3s; }.category-tile:nth-child(2n) { background-color: #733e38; }.category-tile:nth-child(3n) { background-color: #4e5363; }.category-tile:nth-child(4n) { background-color: #7c725a; }.category-tile:nth-child(5n) { background-color: #314f45; }.category-tile:nth-child(6n) { background-color: #623d32; }.category-tile:hover { filter: brightness(1.18); padding-bottom: 50px; }.category-number { position: absolute; top: 28px; color: #ffffff52; font: 11px Georgia,serif; letter-spacing: .12em; }.category-glyph { display: grid; place-items: center; width: 50px; height: 50px; margin-bottom: 24px; border: 1px solid #ffffff42; border-radius: 50%; font-size: 25px; }.category-name { writing-mode: vertical-rl; font-size: 23px; letter-spacing: .2em; }.category-count { display: none; }.category-arrow { position: absolute; bottom: 30px; color: #ffffff85; }
.community-invitation { display: flex; align-items: center; justify-content: space-between; gap: 50px; max-width: 1200px; padding: 85px 48px 95px; margin: auto; }.community-invitation h2 { margin: 17px 0 22px; font-size: 34px; line-height: 1.6; font-weight: 400; letter-spacing: .12em; }.community-invitation p { color: #918677; font: 12px/2.1 'PingFang SC',sans-serif; margin-bottom: 27px; }.community-invitation a { display: flex; align-items: center; justify-content: space-between; padding-bottom: 13px; border-bottom: 1px solid #ab8b66; color: #8a402f; font-size: 13px; max-width: 215px; }.invitation-mark { position: relative; color: #b7a388; padding-right: 60px; }.invitation-mark>svg { width: 210px; height: 210px; opacity: .18; }.invitation-mark span { position: absolute; inset: 60px 110px 60px 60px; line-height: 1.6; font-size: 30px; letter-spacing: .1em; color: #9c7760; white-space: nowrap; }
.scene-fade-enter-active, .scene-fade-leave-active { transition: opacity 1s ease; }.scene-fade-enter-from, .scene-fade-leave-to { opacity: 0; }
.hero-is-paused .hero-still { animation-play-state: paused; }
@keyframes image-drift { from { transform: scale(1.04); } to { transform: scale(1.1); } }
@keyframes caption-enter { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: none; } }
@keyframes down-nudge { 0%,100% { transform: translateY(0); } 50% { transform: translateY(5px); } }
@media(min-width:1600px) { .hero-caption { bottom: 22%; }.hero-caption h1 { font-size: 48px; }.portal-quick-links { padding: 48px 0; } }
@media(max-width:1200px) { .portal-quick-links { padding: 36px 4%; }.quick-links-heading { flex-basis: 180px; }.quick-category { padding: 0 10px; }.quick-category strong { font-size: 12px; }.portal-bulletin { width: calc(100% - 80px); }.portal-intro { gap: 25px; }.intro-lead h2 { font-size: 24px; }.portal-intro>p { font-size: 12px; }.item-image { height: 205px; }.inheritor-wall { gap: 16px; }.inheritor-avatar-card { padding-inline: 12px; }.avatar-border { width: 135px; height: 135px; }.activity-cover { width: 135px; height: 150px; }.activity-card { gap: 18px; }.activity-title { font-size: 16px; }.category-atlas { min-height: 350px; }.atlas-heading { flex-basis: 170px; }.atlas-heading h2 { font-size: 22px; }.category-glyph { width: 38px; height: 38px; font-size: 20px; }.category-name { font-size: 21px; }.book-cover { height: 165px; }.book-content { padding: 17px; }.book-title { font-size: 15px; padding-right: 20px; } }
@media(max-width:900px) { .hero-caption { left: 7%; bottom: 22%; }.hero-caption h1 { font-size: 32px; }.hero-slide-meta { display: none; }.hero-controls { justify-content: flex-end; }.hero-slide-markers { gap: 16px; }.portal-quick-links { flex-wrap: wrap; row-gap: 28px; }.quick-links-heading { flex-basis: 100%; text-align: center; }.quick-links-heading strong { font-size: 25px; }.quick-more { display: none; }.portal-bulletin { grid-template-columns: 145px 1fr; }.bulletin-label { padding-inline: 17px; gap: 11px; }.bulletin-label b { font-size: 18px; }.bulletin-seal { width: 28px; }.bulletin-item { padding: 0 18px; }.bulletin-item span { font-size: 10px; }.portal-intro { display: block; padding-top: 50px; }.portal-intro>p { max-width: 100%; margin-top: 18px; }.featured-items,.inheritor-showcase,.upcoming-activities,.online-courses { padding-block: 55px; }.items-grid,.shelf-row { grid-template-columns: repeat(2,minmax(0,1fr)); gap: 30px 22px; }.item-image { height: 260px; }.book-cover { height: 240px; }.book-title { min-height: unset; margin-bottom: 19px; }.online-courses { padding-top: 0; }.activity-timeline { grid-template-columns: 1fr; }.activity-cover { width: 190px; height: 145px; }.activity-title { font-size: 19px; }.category-atlas { min-height: unset; }.atlas-heading { flex-basis: 155px; }.category-grid { grid-template-columns: repeat(4,1fr); }.category-tile { min-height: 230px; padding: 37px 12px 30px; }.category-number { top: 16px; font-size: 9px; }.category-glyph { width: 32px; height: 32px; font-size: 18px; margin-bottom: 17px; }.category-name { font-size: 18px; }.category-arrow { bottom: 15px; }.community-invitation { padding: 65px 48px; }.community-invitation h2 { font-size: 28px; }.invitation-mark { padding-right: 0; }.invitation-mark>svg { width: 170px; height: 170px; }.invitation-mark span { inset: 46px 40px; font-size: 25px; } }
@media(max-width:600px) { .heritage-hero { height: 92svh; min-height: 600px; max-height: 900px; }.hero-video,.hero-still { object-position: 53% center; }.hero-caption { left: 24px; right: 24px; bottom: 24%; }.hero-caption-kicker { font-size: 10px; margin-bottom: 18px; }.hero-caption h1 { max-width: 310px; font-size: 29px; text-wrap: balance; line-height: 1.7; letter-spacing: .12em; }.hero-caption p { max-width: 255px; font-size: 11px; line-height: 2.1; }.hero-side-note { right: 22px; font-size: 9px; top: 36%; }.hero-controls { left: 24px; right: 24px; bottom: 33px; }.hero-slide-markers { left: 0; transform: none; gap: 12px; }.hero-slide-markers button { width: 25px; height: 25px; padding: 1px; }.hero-control-actions { gap: 10px; }.hero-control-actions button { width: 29px; height: 29px; font-size: 11px; }.hero-play { display: grid; }.portal-quick-links { padding: 32px 22px; row-gap: 23px; }.quick-links-heading strong { font-size: 23px; }.quick-category { flex-basis: 33.333%; flex-grow: 0; margin-top: 0; }.quick-category:nth-child(3n + 2) { border-left: 0; }.quick-category strong { font-size: 13px; }.quick-category>span:first-child { width: 32px; height: 32px; font-size: 17px; }.portal-bulletin { width: calc(100% - 44px); margin-top: 30px; padding: 23px 0; grid-template-columns: 72px 1fr; }.bulletin-label { padding: 0; justify-content: center; border: 0; }.bulletin-label>span:last-child { display: none; }.bulletin-seal { width: 32px; }.bulletin-items { grid-template-columns: 1fr; }.bulletin-item { padding: 12px 16px 12px 0; border: 0; }.bulletin-item:first-child { padding-top: 0; }.bulletin-item:last-child { padding-bottom: 0; }.bulletin-item small { display: inline; font-size: 9px; margin-right: 12px; }.bulletin-item strong { display: inline; font-size: 16px; }.bulletin-item span { display: block; margin-top: 5px; font-size: 10px; }.portal-intro { width: calc(100% - 44px); padding: 43px 0 0; }.intro-lead h2 { font-size: 24px; }.portal-intro>p { font-size: 11px; }.featured-items,.inheritor-showcase,.upcoming-activities,.online-courses { width: calc(100% - 44px); padding-block: 44px; }.section-header { gap: 17px; margin-bottom: 27px; }.section-eyebrow { font-size: 8px; letter-spacing: .09em; }.section-title { font-size: 25px; letter-spacing: .12em; margin-top: 6px; }.section-divider { display: none; }.section-header { justify-content: space-between; }.section-header :deep(.ant-btn-link) { font-size: 10px; }.section-header :deep(.ant-btn-link .anticon) { margin-left: 8px; }.items-grid,.shelf-row { gap: 24px 15px; }.item-image { height: 170px; }.item-card { padding-bottom: 17px; }.item-content { padding-top: 14px; }.item-title { font-size: 15px; margin-bottom: 7px; }.item-category-tag { top: 8px; left: 8px; font-size: 9px; padding: 5px 7px; }.item-region { font-size: 9px; margin-bottom: 9px; }.item-summary { font-size: 10px; line-height: 1.8; }.inheritor-wall { grid-template-columns: repeat(2,minmax(0,1fr)); gap: 30px 12px; }.inheritor-avatar-card { padding: 0 7px; }.inheritor-avatar-card:nth-child(2n) { border: 0; }.avatar-border { width: 116px; height: 116px; padding: 5px; }.avatar-container { margin-bottom: 15px; }.avatar-title-badge { font-size: 8px; padding: 3px 5px; max-width: 146px; }.inheritor-name { font-size: 20px; }.inheritor-region { font-size: 10px; }.inheritor-excerpt { font-size: 10px; -webkit-line-clamp: 2; margin: 12px 0 14px; }.inheritor-link { font-size: 9px; }.activity-timeline { gap: 22px; }.activity-cover { width: 115px; height: 138px; }.activity-card { gap: 15px; padding-bottom: 21px; }.activity-time { font-size: 9px; }.activity-title { font-size: 15px; margin-block: 9px; }.activity-location { font-size: 9px; }.activity-desc { font-size: 9px; margin-top: 7px; }.book-cover { height: 150px; }.book-content { padding: 14px; }.book-title { min-height: 45px; font-size: 13px; margin-bottom: 11px; }.book-level { right: 10px; top: 15px; font-size: 8px; padding: 4px 2px; }.course-excerpt { font-size: 9px; margin-bottom: 13px; }.course-entry { font-size: 9px; padding-top: 10px; }.course-play { width: 32px; height: 32px; font-size: 11px; }.online-courses { padding-top: 0; }.category-atlas { flex-direction: column; }.atlas-heading { flex-basis: auto; flex-direction: row; gap: 20px; padding: 30px 20px; }.atlas-heading h2 { writing-mode: unset; margin: 0; font-size: 24px; }.atlas-heading>svg { width: 19px; height: 19px; }.category-tile { min-height: 212px; }.community-invitation { padding: 49px 24px; gap: 10px; }.community-invitation h2 { font-size: 25px; }.community-invitation p { font-size: 10px; }.community-invitation a { font-size: 11px; max-width: 180px; }.invitation-mark { display: none; } }
@media(max-width:900px) { .hero-controls { display: grid; grid-template-columns: 1fr auto; gap: 20px; }.hero-slide-markers { position: static; transform: none; }.hero-control-actions { gap: 14px; } }
@media(max-width:600px) { .hero-controls { gap: 8px; }.hero-slide-markers { gap: 5px; }.hero-slide-markers button { width: 24px; height: 27px; }.hero-control-actions { gap: 5px; }.hero-control-actions button { width: 27px; height: 27px; } }
@media(prefers-reduced-motion:reduce) { *, *:before, *:after { animation: none !important; transition: none !important; scroll-behavior: auto !important; } }
@media(max-width:760px) { :global(.home-snap-page) { scroll-snap-type: y proximity; } :global(.home-snap-page) [data-snap-section] { scroll-snap-align: start; } }
@media(prefers-reduced-motion:reduce) { :global(.home-snap-page) { scroll-snap-type: none; scroll-behavior: auto; } }
</style>
