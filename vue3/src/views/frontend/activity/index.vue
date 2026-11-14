<template>
  <div class="activity-list">
    <PortalPageHeader
      eyebrow="HERITAGE IN THE PRESENT"
      title="活动 · 现场"
      description="从一场展演、一回手作出发，在真实的文化现场遇见非遗。"
      mark="现场"
      image="/images/hero-scene-3.jpg"
    />

    <section
      ref="spotlightSection"
      class="activity-spotlight"
      aria-label="非遗活动精选轮播"
      @mouseenter="hoverPaused = true"
      @mouseleave="hoverPaused = false"
      @focusin="focusPaused = true"
      @focusout="handleSpotlightFocusOut"
      @touchstart.passive="handleSwipeStart"
      @touchend.passive="handleSwipeEnd"
    >
      <Transition name="spotlight-scene" mode="out-in">
        <div :key="featuredActivity.id" class="spotlight-layout">
          <router-link :to="`/activity/${featuredActivity.id}`" class="spotlight-picture" :aria-label="`了解${featuredActivity.title}`">
            <img :src="featuredActivity.cover" :alt="featuredActivity.imageAlt">
            <span class="spotlight-picture-note">{{ featuredActivity.imageSource ? '活动公开报道影像' : '活动主题视觉 · 非现场照片' }}</span>
          </router-link>
          <div class="spotlight-story">
            <span class="spotlight-kicker">{{ featuredActivity.eyebrow }}</span>
            <span class="spotlight-status">{{ getVerifiedStatus(featuredActivity) }}</span>
            <h2>{{ featuredActivity.title }}</h2>
            <p>{{ featuredActivity.summary }}</p>
            <div class="spotlight-meta"><span>{{ formatDate(featuredActivity.startTime) }} — {{ formatDate(featuredActivity.endTime) }}</span><span>{{ featuredActivity.location }}</span></div>
            <router-link :to="`/activity/${featuredActivity.id}`" class="spotlight-link">走进这场文化相遇 <span aria-hidden="true">↗</span></router-link>
          </div>
        </div>
      </Transition>
      <div class="spotlight-controls">
        <span class="spotlight-index">0{{ featuredIndex + 1 }} <i /> 0{{ verifiedActivities.length }}</span>
        <div class="spotlight-dots" role="group" aria-label="选择精选活动">
          <button v-for="(item, index) in verifiedActivities" :key="item.id" type="button" :class="{ active: index === featuredIndex }" :aria-label="`查看精选活动${index + 1}：${item.title}`" :aria-pressed="index === featuredIndex" @click="selectFeatured(index)"><span /></button>
        </div>
        <div class="spotlight-arrows">
          <button type="button" :aria-label="rotationPaused ? '继续自动轮播' : '暂停自动轮播'" @click="rotationPaused = !rotationPaused">{{ rotationPaused ? '▷' : 'Ⅱ' }}</button>
          <button type="button" aria-label="上一个精选活动" @click="selectFeatured(featuredIndex - 1)">←</button>
          <button type="button" aria-label="下一个精选活动" @click="selectFeatured(featuredIndex + 1)">→</button>
        </div>
      </div>
    </section>

    <div class="collection-heading">
      <div><span class="section-kicker">CULTURAL CALENDAR</span><h2>走进非遗的发生地</h2></div><p>共 <strong>{{ pagination.total }}</strong> 场文化活动</p>
    </div>
    <!-- 搜索筛选 -->
    <div class="search-section">
      <a-row :gutter="[16, 16]">
        <a-col
          :xs="24"
          :sm="8"
          :lg="8"
        >
          <a-input
            v-model:value="searchForm.title"
            placeholder="搜索活动标题"
            allow-clear
            @press-enter="handleSearch"
          >
            <template #prefix>
              <i class="fas fa-search" />
            </template>
          </a-input>
        </a-col>
        <a-col
          :xs="12"
          :sm="5"
          :lg="5"
        >
          <a-select
            v-model:value="searchForm.type"
            placeholder="活动类型"
            allow-clear
            style="width: 100%"
          >
            <a-select-option value="展演">
              展演
            </a-select-option>
            <a-select-option value="展览">
              展览
            </a-select-option>
            <a-select-option value="培训">
              培训
            </a-select-option>
            <a-select-option value="交流">交流</a-select-option>
            <a-select-option value="比赛">
              比赛
            </a-select-option>
          </a-select>
        </a-col>
        <a-col
          :xs="12"
          :sm="5"
          :lg="5"
        >
          <a-select
            v-model:value="searchForm.status"
            placeholder="活动状态"
            allow-clear
            style="width: 100%"
          >
            <a-select-option :value="1">
              报名 / 预告
            </a-select-option>
            <a-select-option :value="2">
              进行中
            </a-select-option>
            <a-select-option :value="3">
              已结束
            </a-select-option>
          </a-select>
        </a-col>
        <a-col
          :xs="12"
          :sm="6"
          :lg="6"
        >
          <a-button
            type="primary"
            block
            @click="handleSearch"
          >
            <i class="fas fa-search" /> 搜索
          </a-button>
        </a-col>
      </a-row>
    </div>

    <section class="verified-collection" aria-labelledby="verified-collection-title">
      <div class="collection-heading verified-heading">
        <div>
          <span class="section-kicker">VERIFIED CULTURAL CALENDAR</span>
          <h2 id="verified-collection-title">近期活动与现场回顾</h2>
        </div>
        <p>公开报道 · <strong>{{ verifiedActivities.length }}</strong> 场</p>
      </div>
      <div class="activity-grid verified-activity-grid">
        <a-row :gutter="[24, 24]">
          <a-col
            v-for="activity in verifiedActivities"
            :key="activity.id"
            :xs="24"
            :sm="12"
            :md="12"
            :lg="12"
          >
            <article
              class="activity-card"
              role="link"
              tabindex="0"
              @click="goToDetail(activity.id)"
              @keydown.enter.self="goToDetail(activity.id)"
            >
              <div class="activity-cover">
                <img :src="activity.cover" :alt="activity.imageAlt" loading="lazy">
                <div class="activity-status">
                  <a-tag>{{ getVerifiedStatus(activity) }}</a-tag>
                </div>
              </div>
              <div class="activity-content">
                <div class="calendar-date">
                  <strong>{{ formatDate(activity.startTime).slice(8,10) }}</strong>
                  <span>{{ formatDate(activity.startTime).slice(0,7) }}</span>
                </div>
                <h3 class="activity-title">{{ activity.title }}</h3>
                <div class="activity-meta">
                  <div class="meta-item"><i class="fas fa-tag" /><span>{{ activity.type }}</span></div>
                  <div class="meta-item"><i class="fas fa-map-marker-alt" /><span>{{ activity.location }}</span></div>
                  <div class="meta-item"><i class="fas fa-calendar" /><span>{{ formatDate(activity.startTime) }}</span></div>
                </div>
                <small class="verified-note">{{ activity.sourceName }} · 查看来源与活动档案</small>
                <div class="activity-action"><a-button size="small">查看活动档案 ↗</a-button></div>
              </div>
            </article>
          </a-col>
        </a-row>
      </div>
    </section>

    <!-- 活动列表 -->
    <div class="activity-grid">
      <a-spin :spinning="loading">
        <a-row :gutter="[24, 24]">
          <a-col
            v-for="activity in activityList"
            :key="activity.id"
            :xs="24"
            :sm="12"
            :md="12"
            :lg="12"
          >
            <div
              class="activity-card"
              role="link"
              tabindex="0"
              @click="goToDetail(activity.id)"
              @keydown.enter.self="goToDetail(activity.id)"
            >
              <div class="activity-cover">
                <img
                  :src="getActivityCover(activity)"
                  :alt="getActivityImageAlt(activity)"
                >
                <p v-if="showCoverCredit(activity)" class="activity-cover-credit">{{ verifiedById[activity.id].imageCredit }}</p>
                <div class="activity-status">
                  <a-tag :color="getStatusColor(activity.status)">
                    {{ getActivityStatus(activity) }}
                  </a-tag>
                </div>
              </div>
              <div class="activity-content">
                <div class="calendar-date">
                  <strong>{{ formatDate(activity.startTime).slice(8,10) }}</strong><span>{{ formatDate(activity.startTime).slice(0,7) }}</span>
                </div>
                <h3 class="activity-title">
                  {{ activity.title }}
                </h3>
                <div class="activity-meta">
                  <div class="meta-item">
                    <i class="fas fa-tag" />
                    <span>{{ activity.type }}</span>
                  </div>
                  <div class="meta-item">
                    <i class="fas fa-map-marker-alt" />
                    <span>{{ activity.location || '待定' }}</span>
                  </div>
                  <div class="meta-item">
                    <i class="fas fa-calendar" />
                    <span>{{ formatDate(activity.startTime) }}</span>
                  </div>
                </div>
                <small v-if="verifiedById[activity.id]" class="verified-note"><a :href="verifiedById[activity.id].sourceUrl" target="_blank" rel="noopener noreferrer" @click.stop>{{ verifiedById[activity.id].sourceName }} · 阅读官方报道 ↗</a></small>
                <div class="activity-action">
                  <a-button
                    v-if="activity.status === 1 && !verifiedById[activity.id]"
                    type="primary"
                    size="small"
                    @click.stop="handleSignup(activity)"
                  >
                    立即报名
                  </a-button>
                  <a-button
                    v-else
                    size="small"
                  >
                    {{ verifiedById[activity.id] ? '查看活动档案 ↗' : '走进现场 ↗' }}
                  </a-button>
                </div>
              </div>
            </div>
          </a-col>
        </a-row>

        <!-- 空状态 -->
        <a-empty
          v-if="!loading && activityList.length === 0"
          description="暂无活动"
        />
      </a-spin>
    </div>

    <!-- 分页 -->
    <div
      v-if="pagination.total > 0"
      class="pagination-section"
    >
      <a-pagination
        v-model:current="pagination.current"
        v-model:page-size="pagination.pageSize"
        :total="pagination.total"
        :show-size-changer="true"
        :show-total="total => `共 ${total} 条`"
        @change="handlePageChange"
      />
    </div>

    <!-- 报名弹窗 -->
    <a-modal
      v-model:open="isSignupModalVisible"
      title="活动报名"
      @ok="handleSignupOk"
      @cancel="isSignupModalVisible = false"
    >
      <div class="signup-info">
        <h3>{{ selectedActivity?.title }}</h3>
        <p><strong>活动时间：</strong>{{ formatDateTime(selectedActivity?.startTime) }} 至 {{ formatDateTime(selectedActivity?.endTime) }}</p>
        <p><strong>活动地点：</strong>{{ selectedActivity?.location }}</p>
        <p><strong>活动类型：</strong>{{ selectedActivity?.type }}</p>
        <a-alert
          message="温馨提示"
          description="提交报名后，我们会尽快审核您的申请，请保持手机畅通。"
          type="info"
          show-icon
          style="margin-top: 16px"
        />
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { getActivityPage, signupActivity } from '@/api/ActivityApi'
import { useUserStore } from '@/store/user'
import { withDisplayYear } from '@/utils/dateUtils'
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'
import verifiedActivities from '@/data/verifiedActivities.json'
import activityArchives from '@/data/activityArchives.json'

const router = useRouter()
const userStore = useUserStore()
const verifiedById = Object.fromEntries([...verifiedActivities, ...activityArchives].map(item => [item.id, item]))
const spotlightSection = ref(null)
const spotlightVisible = ref(false)
const featuredIndex = ref(0)
const featuredActivity = computed(() => verifiedActivities[featuredIndex.value])
const hoverPaused = ref(false)
const focusPaused = ref(false)
const rotationPaused = ref(false)
let rotationTimer
let spotlightObserver
let swipeOrigin
let motionQuery
const motionReduced = ref(false)
const selectFeatured = (index) => {
  featuredIndex.value = (index + verifiedActivities.length) % verifiedActivities.length
}
const getVerifiedStatus = (item) => {
  const startsAt = item.startTime ? dayjs(item.startTime) : null
  const endsAt = item.endTime ? dayjs(item.endTime) : null
  if (startsAt?.isValid() && dayjs().isBefore(startsAt)) return '即将举行 · 官方资讯'
  if (endsAt?.isValid() && dayjs().isAfter(endsAt)) return '活动回顾'
  if (!startsAt?.isValid() || !endsAt?.isValid()) return item.statusName || '官方活动资讯'
  return '进行中 · 官方资讯'
}
const getActivityStatus = (item) => verifiedById[item.id] ? getVerifiedStatus({ ...verifiedById[item.id], ...item }) : item.statusName
const updateMotionPreference = () => { motionReduced.value = motionQuery?.matches || false }
const handleSpotlightFocusOut = (event) => {
  if (!event.currentTarget.contains(event.relatedTarget)) focusPaused.value = false
}
const handleSwipeStart = (event) => {
  const touch = event.touches[0]
  swipeOrigin = touch ? { x: touch.clientX, y: touch.clientY } : null
}
const handleSwipeEnd = (event) => {
  const touch = event.changedTouches[0]
  if (!touch || !swipeOrigin) return
  const dx = touch.clientX - swipeOrigin.x
  const dy = touch.clientY - swipeOrigin.y
  if (Math.abs(dx) > 65 && Math.abs(dx) > Math.abs(dy) * 1.6) selectFeatured(featuredIndex.value + (dx < 0 ? 1 : -1))
  swipeOrigin = null
}


// 搜索表单
const searchForm = reactive({
  title: '',
  type: undefined,
  status: undefined // 默认浏览全部活动，含近期资讯与活动回顾
})

// 活动列表
const activityList = ref([])
const loading = ref(false)
const pagination = reactive({
  current: 1,
  pageSize: 12,
  total: 0
})

// 报名相关
const isSignupModalVisible = ref(false)
const selectedActivity = ref(null)

// 本地封面兜底，避免外部占位图服务不可用时出现空白卡片。
const activityFallbackCover = '/images/activity-placeholder.svg'

// 加载数据
const loadData = () => {
  loading.value = true
  getActivityPage(
    {
      current: pagination.current,
      size: pagination.pageSize,
      ...searchForm
    },
    {
      onSuccess: (data) => {
        activityList.value = data.records || []
        pagination.total = data.total || 0
        loading.value = false
      },
      onError: () => {
        loading.value = false
      }
    }
  )
}

// 搜索
const handleSearch = () => {
  pagination.current = 1
  loadData()
}

// 分页变化
const handlePageChange = () => {
  loadData()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// 跳转详情
const goToDetail = (id) => {
  router.push(`/activity/${id}`)
}

// 报名
const handleSignup = (activity) => {
  if (!userStore.isLoggedIn) {
    message.warning('请先登录')
    router.push({ path: '/auth/login', query: { redirect: '/activity' } })
    return
  }

  selectedActivity.value = activity
  isSignupModalVisible.value = true
}

// 确认报名
const handleSignupOk = () => {
  if (!userStore.userId) {
    message.error('用户信息异常')
    return
  }

  // 活动ID是字符串格式（UUID），直接使用
  const activityId = selectedActivity.value.id
  if (!activityId) {
    message.error('活动ID不能为空')
    return
  }

  signupActivity(
    {
      activityId: activityId, // 直接使用字符串ID
      userId: userStore.userId
    },
    {
      onSuccess: () => {
        message.success('报名成功，请等待审核')
        isSignupModalVisible.value = false
        selectedActivity.value = null
      },
      successMsg: false
    }
  )
}

// 工具函数
const getStatusColor = (status) => {
  const colors = {
    1: 'blue',
    2: 'green',
    3: 'gray'
  }
  return colors[status] || 'default'
}

const getActivityCover = (activity) => {
  if (activity.coverFilePath) {
    const path = activity.coverFilePath
    if (path.startsWith('http')) return path
    // 静态资源直接访问，不需要API前缀
    return path.startsWith('/') ? path : '/' + path
  }
  if (verifiedById[activity.id]?.cover) return verifiedById[activity.id].cover
  return activityFallbackCover
}
const showCoverCredit = (activity) => Boolean(verifiedById[activity.id]?.imageCredit && getActivityCover(activity) === verifiedById[activity.id].cover)
const getActivityImageAlt = (activity) => showCoverCredit(activity) ? verifiedById[activity.id].imageAlt : activity.title

const formatDate = (dateStr) => {
  const date = withDisplayYear(dateStr)
  return date ? dayjs(date).format('YYYY-MM-DD') : '-'
}

const formatDateTime = (dateStr) => {
  const date = withDisplayYear(dateStr)
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-'
}

// 页面加载
onMounted(() => {
  loadData()
  motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)')
  updateMotionPreference()
  motionQuery.addEventListener?.('change', updateMotionPreference)
  if ('IntersectionObserver' in window) {
    spotlightObserver = new IntersectionObserver(([entry]) => { spotlightVisible.value = entry.isIntersecting }, { threshold: 0.2 })
    spotlightObserver.observe(spotlightSection.value)
  } else {
    spotlightVisible.value = true
  }
  rotationTimer = window.setInterval(() => {
    if (spotlightVisible.value && !rotationPaused.value && !hoverPaused.value && !focusPaused.value && !motionReduced.value && !document.hidden) {
      selectFeatured(featuredIndex.value + 1)
    }
  }, 7000)
})
onBeforeUnmount(() => {
  window.clearInterval(rotationTimer)
  spotlightObserver?.disconnect()
  motionQuery?.removeEventListener?.('change', updateMotionPreference)
})
</script>

<style scoped>
.activity-spotlight { width:calc(100% - 96px);max-width:1280px;margin:48px auto 0;background:#253b33;color:#f3ebdb;position:relative;overflow:hidden;border:1px solid #b7a17b; }
.spotlight-layout { display:grid;grid-template-columns:1.16fr 1fr;min-height:420px; }
.spotlight-picture { position:relative;display:block;overflow:hidden;min-height:420px;background:#30372c; }
.spotlight-picture img { width:100%;height:100%;position:absolute;inset:0;object-fit:cover;transition:transform 1.2s cubic-bezier(.2,.6,.3,1); }.spotlight-picture:hover img { transform:scale(1.04); }
.spotlight-picture:after { content:'';position:absolute;inset:0;pointer-events:none;background:linear-gradient(0deg,#101e2190,transparent 35%); }.spotlight-picture-note { position:absolute;bottom:20px;left:24px;z-index:1;color:#ede6d5;font-size:10px;letter-spacing:.12em; }
.spotlight-story { padding:42px 40px 34px;position:relative;display:flex;flex-direction:column;align-items:flex-start; }.spotlight-story:after { content:'';position:absolute;inset:10px;border:1px solid #b6a07828;pointer-events:none; }
.spotlight-kicker { font:10px/1.8 Arial,sans-serif;letter-spacing:.16em;color:#bca783; }.spotlight-status { color:#d4c5a8;border:1px solid #bda57566;padding:3px 10px;margin-top:18px;font-size:10px;letter-spacing:.1em; }
.spotlight-story h2 { color:#f3ead7;font:400 clamp(22px,2.2vw,31px)/1.65 'Songti SC','SimSun',serif;margin:17px 0 16px;letter-spacing:.06em; }.spotlight-story p { font-size:12px;line-height:2;color:#c1c5b6;margin:0 0 20px; }.spotlight-meta { display:flex;flex-direction:column;gap:7px;color:#b5b7a3;font-size:10px;line-height:1.7; }.spotlight-link { display:flex;align-items:center;gap:30px;margin-top:auto;padding-top:25px;color:#e4cfa6;font-size:12px;letter-spacing:.13em; }.spotlight-link:hover { color:#fff2ce; }.spotlight-link span { transition:transform .3s; }.spotlight-link:hover span { transform:translate(4px,-4px); }
.spotlight-controls { min-height:68px;border-top:1px solid #b7a17b35;display:flex;align-items:center;gap:25px;padding:0 28px; }.spotlight-index { display:flex;align-items:center;gap:12px;font:16px Georgia,serif;color:#d6c5a5; }.spotlight-index i { display:block;width:26px;height:1px;background:#998f74; }.spotlight-dots { display:flex;gap:4px;margin:auto; }.spotlight-dots button { width:31px;min-height:42px;border:0;background:transparent;display:grid;place-items:center;cursor:pointer; }.spotlight-dots span { width:6px;height:6px;border:1px solid #baaa88;transform:rotate(45deg);transition:background .3s,transform .3s; }.spotlight-dots .active span { background:#d8bf8f;transform:rotate(45deg) scale(1.5); }
.spotlight-arrows { display:flex;gap:8px; }.spotlight-arrows button { width:35px;height:35px;border:1px solid #a9967066;color:#dac9a7;background:transparent;cursor:pointer;transition:background .25s,border-color .25s; }.spotlight-arrows button:hover { background:#ad967044;border-color:#d8bf8f; }
.spotlight-scene-enter-active,.spotlight-scene-leave-active { transition:opacity .3s,transform .4s; }.spotlight-scene-enter-from { opacity:0;transform:translateY(7px); }.spotlight-scene-leave-to { opacity:0;transform:translateY(-5px); }
.verified-note { color:#9b8061;font-size:10px;letter-spacing:.04em;margin-top:10px; }
@media(max-width:991px) { .spotlight-layout { grid-template-columns:1fr 1fr;min-height:390px; }.spotlight-picture { min-height:390px; }.spotlight-story { padding:30px 27px; }.spotlight-story h2 { font-size:23px; } }
@media(max-width:760px) { .activity-spotlight { width:calc(100% - 44px);margin-top:28px; }.spotlight-layout { grid-template-columns:1fr; }.spotlight-picture { min-height:0;height:225px; }.spotlight-story { padding:28px 24px;min-height:385px; }.spotlight-story h2 { font-size:24px; }.spotlight-story p { font-size:12px; }.spotlight-controls { padding:10px 15px;gap:9px;flex-wrap:wrap; }.spotlight-index { font-size:12px;gap:7px; }.spotlight-index i { width:15px; }.spotlight-dots { gap:0; }.spotlight-dots button { width:20px; }.spotlight-arrows { gap:5px; }.spotlight-arrows button { width:29px;height:32px; } }
@media(prefers-reduced-motion:reduce) { .spotlight-picture img,.spotlight-link span,.spotlight-dots span,.spotlight-scene-enter-active,.spotlight-scene-leave-active { transition:none; } }


.collection-heading { max-width: 1280px; width: calc(100% - 96px); margin: 56px auto 25px; display: flex; align-items: flex-end; justify-content: space-between; gap: 24px; }
.verified-collection { padding: 1px 0 10px; background: linear-gradient(180deg,#f1ecdf 0%,#f7f4ec 78%); border-top: 1px solid #ded2bd; border-bottom: 1px solid #ded2bd; }
.verified-heading { margin-top: 42px; }
.verified-heading p { color: #8f8371; }
.verified-activity-grid { padding-bottom: 38px; }
.verified-activity-grid .activity-card { border-color: #cfc1a8; }
.verified-activity-grid .activity-content { background: linear-gradient(145deg,#fffdf7,#f7f1e5); }
.verified-activity-grid .verified-note { margin-top: 11px; line-height: 1.8; }
.verified-activity-grid .activity-action { margin-top: 12px; }
.activity-cover-credit { position:absolute;bottom:0;left:0;right:0;margin:0;padding:10px 12px;background:linear-gradient(transparent,#17241fe6);color:#fff8e9;font-size:9px;line-height:1.7; }.verified-note a { color:inherit; }.verified-note a:hover { color:#96392b; }
.verified-activity-grid .activity-status :deep(.ant-tag) { max-width: calc(100vw - 80px); }
.section-kicker, .course-kicker { font: 10px/1.6 Arial,sans-serif; color: #aa8e66; letter-spacing: .18em; }
.collection-heading h2 { margin: 12px 0 0; font: 400 29px/1.5 'Songti SC','SimSun',serif; letter-spacing: .1em; color: #34372f; }
.collection-heading p { margin: 0 0 4px; font-size: 12px; color: #8f8371; white-space: nowrap; }.collection-heading strong { font: 27px Georgia,serif; color: #a03328; padding: 0 5px; }
.search-section { width: calc(100% - 96px); max-width: 1280px; margin: 0 auto 38px; padding: 24px 0; border-top: 1px solid #cfc3af; border-bottom: 1px solid #cfc3af; }
.search-section :deep(.ant-input-affix-wrapper),.search-section :deep(.ant-select-selector),.search-section :deep(.ant-input) { border-radius: 0; min-height: 40px; background: #fbf8f1; border-color: #d7cdbb; }.search-section :deep(.ant-input-affix-wrapper .ant-input) { min-height: auto; }.search-section :deep(.ant-select-selector) { display: flex; align-items: center; }.search-section :deep(.ant-btn) { height: 40px; border-radius: 0; letter-spacing: .15em; }.search-section :deep(.ant-btn-primary) { background: #9f3026; border-color: #9f3026; }.search-section :deep(.ant-btn-primary:hover) { background: #7f211a; border-color: #7f211a; }
.pagination-section { max-width: 1280px; margin: 0 auto; padding: 40px 0 64px; display: flex; justify-content: center; }.pagination-section :deep(.ant-pagination-item) { border-radius: 0; }.pagination-section :deep(.ant-pagination-item-active) { border-color: #9f3026; background: #9f3026; }.pagination-section :deep(.ant-pagination-item-active a) { color: #fff; }
@media(max-width:760px) { .collection-heading,.search-section { width: calc(100% - 44px); }.collection-heading { margin-top: 35px; gap: 16px; }.collection-heading h2 { font-size: 22px; }.collection-heading p { font-size: 10px; }.collection-heading strong { font-size: 21px; }.section-kicker { font-size: 8px; }.search-section { padding: 18px 0; margin-bottom: 27px; }.pagination-section { padding: 30px 20px 45px; }.pagination-section :deep(.ant-pagination-options) { display: none; } }
@media(max-width:760px) { .verified-heading { margin-top: 30px; }.verified-activity-grid { padding-bottom: 24px; } }

.activity-list { min-height: 100vh; padding-bottom: 5px; background: #f7f4ec; }
.activity-grid { max-width: 1280px; width: calc(100% - 96px); min-height: 360px; margin: auto; }.activity-grid :deep(.ant-col) { display: flex; }
.activity-card { display: grid; grid-template-columns: minmax(0, .9fr) minmax(0,1fr); width: 100%; border: 1px solid #d4c8b5; background: #fdfbf5; cursor: pointer; transition: transform .35s,box-shadow .35s; }
.activity-card:hover { transform: translateY(-4px); box-shadow: 0 12px 25px #433a2910; }.activity-card:focus-visible { outline: 2px solid #9f3026; outline-offset: 4px; }
.activity-cover { position: relative; min-height: 290px; overflow: hidden; }.activity-cover img { width: 100%; height: 100%; object-fit: cover; display: block; transition: transform .65s; }.activity-card:hover .activity-cover img { transform: scale(1.055); }.activity-status { position: absolute; top: 13px; left: 13px; }.activity-status :deep(.ant-tag) { border: 0; border-radius: 0; background: #243e35ed; color: #f3ebd8; font-size: 10px; padding: 3px 9px; }
.activity-content { min-width: 0; padding: 22px 24px; position: relative; display: flex; flex-direction: column; }.calendar-date { display: flex; align-items: baseline; gap: 9px; padding-bottom: 13px; margin-bottom: 16px; border-bottom: 1px solid #dfd4c2; color: #a02e25; }.calendar-date strong { font: 36px/.95 Georgia,serif; }.calendar-date span { font: 10px Arial,sans-serif; color: #9e8c70; letter-spacing: .08em; }
.activity-title { font: 400 20px/1.55 'Songti SC','SimSun',serif; letter-spacing: .06em; color: #34372f; margin: 0 0 16px; }.activity-meta { flex: 1; }.meta-item { display: flex; align-items: flex-start; gap: 8px; font-size: 11px; line-height: 1.8; color: #8a8172; margin: 5px 0; }.meta-item i { color: #ae9875; margin-top: 4px; width: 12px; flex-shrink: 0; }.meta-item:last-child { display: none; }.activity-action { margin-top: 17px; }.activity-action :deep(.ant-btn) { border-radius: 0; height: 32px; width: 100%; font-size: 11px; letter-spacing: .12em; border-color: #c6b89d; background: transparent; color: #8c3c2e; }.activity-action :deep(.ant-btn-primary) { color: #fff9e9; border-color: #a02e25; background: #a02e25; }
.signup-info { color: #625747; }.signup-info h3 { font-family: 'Songti SC',serif; font-size: 22px; }.signup-info p { line-height: 1.9; font-size: 13px; }
@media(max-width:1100px) { .activity-card { grid-template-columns: 1fr; }.activity-cover { min-height: unset; height: 230px; }.activity-content { padding: 22px; }.calendar-date { position: absolute; top: -51px; right: 14px; background: #f8f3e7; padding: 11px 12px; min-width: 102px; }.calendar-date strong { font-size: 29px; }.activity-title { padding-top: 2px; font-size: 20px; } }
@media(max-width:760px) { .activity-grid { width: calc(100% - 44px); }.activity-cover { height: 215px; }.activity-content { padding: 22px; }.activity-title { font-size: 19px; }.activity-card { margin-bottom: 2px; } }

</style>
