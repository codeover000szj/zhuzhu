<template>
  <div class="course-list">
    <PortalPageHeader
      eyebrow="LEARN A CRAFT, KEEP IT ALIVE"
      title="课堂 · 传习"
      description="循着章法学一门手艺，让知识、实践与交流连接成完整的学习旅程。"
      mark="传习"
      image="/images/hero-scene-5.jpg"
    />

    <div class="collection-heading">
      <div><span class="section-kicker">THE ONLINE ACADEMY</span><h2>每一门手艺，都有章法</h2></div><p>共 <strong>{{ pagination.total }}</strong> 门传习课程</p>
    </div>
    <div v-if="spotlightSlides.length" class="course-spotlight-wrap">
      <PortalSpotlightCarousel
        :slides="spotlightSlides"
        label="在线传习精选课程"
        eyebrow="THE CRAFT OF LEARNING / 传习精选"
        action-text="探索这门课程"
      />
    </div>
    <!-- 搜索筛选 -->
    <div class="search-section">
      <a-row :gutter="[16, 16]">
        <a-col
          :xs="24"
          :sm="12"
          :lg="10"
        >
          <a-input
            v-model:value="searchForm.title"
            placeholder="搜索课程标题"
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
          :sm="6"
          :lg="8"
        >
          <a-select
            v-model:value="searchForm.level"
            placeholder="难度等级"
            allow-clear
            style="width: 100%"
          >
            <a-select-option
              v-for="option in COURSE_LEVEL_OPTIONS"
              :key="option.value"
              :value="option.value"
            >
              {{ option.label }}
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

    <!-- 课程列表 -->
    <div class="course-grid">
      <a-spin :spinning="loading">
        <a-row :gutter="[24, 24]">
          <a-col
            v-for="course in courseList"
            :key="course.id"
            :xs="24"
            :sm="12"
            :md="8"
            :lg="8"
          >
            <div
              class="course-card"
              role="link"
              tabindex="0"
              @click="goToDetail(course.id)"
              @keydown.enter.self="goToDetail(course.id)"
            >
              <div class="course-cover">
                <img
                  :src="getCourseMedia(course.title).cover"
                  :alt="getCourseMedia(course.title).coverAlt"
                  loading="lazy"
                >
                <span class="cover-label"><i class="fas fa-circle-play" /> 视频课程</span>
              </div>
              <div class="course-content">
                <span class="course-kicker">非遗传习 · ONLINE CLASS</span>
                <div class="course-header-row">
                  <h3 class="course-title">
                    {{ course.title }}
                  </h3>
                  <a-tag :color="getCourseLevelColor(course.level)">
                    {{ getCourseLevelName(course.level) }}
                  </a-tag>
                </div>
                <div class="course-meta">
                  <div class="meta-item">
                    <i class="fas fa-book" />
                    <span>{{ course.chapterCount ? `${course.chapterCount} 章节` : '章节整理中' }}</span>
                  </div>
                  <div class="meta-item">
                    <i class="fas fa-signal" />
                    <span>{{ getCourseLevelName(course.level) }}</span>
                  </div>
                </div>
                <div class="course-action">
                  <a-button
                    type="text"
                    size="small"
                  >
                    进入课堂 <span aria-hidden="true">↗</span>
                  </a-button>
                </div>
              </div>
            </div>
          </a-col>
        </a-row>

        <!-- 空状态 -->
        <a-empty
          v-if="!loading && courseList.length === 0"
          description="暂无课程"
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
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getCoursePage } from '@/api/CourseApi'
import { COURSE_LEVEL_OPTIONS, getCourseLevelName, getCourseLevelColor } from '@/config/courseLevel'
import { getCourseMedia } from '@/config/heritageMedia'
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'
import PortalSpotlightCarousel from '@/components/frontend/PortalSpotlightCarousel.vue'

const router = useRouter()

// 搜索表单
const searchForm = reactive({
  title: '',
  level: undefined,
  status: 1 // 只显示已发布的课程
})

// 课程列表
const courseList = ref([])
const spotlightSlides = computed(() => courseList.value.slice(0, 4).map(course => ({
  id: course.id, title: course.title, image: getCourseMedia(course.title).cover,
  alt: getCourseMedia(course.title).coverAlt,
  description: course.description || `循着${getCourseMedia(course.title).videoTitle}的学习线索，从文化背景、基础知识走向实践观察。结合章节导读、视频资料与共学交流，逐步读懂一门手艺。`,
  tag: getCourseLevelName(course.level), meta: '学一门技艺 · 留一份文化记忆',
  to: `/course/${course.id}`
})))
const loading = ref(false)
const pagination = reactive({
  current: 1,
  pageSize: 12,
  total: 0
})

// 加载数据
const loadData = () => {
  loading.value = true
  getCoursePage(
    {
      current: pagination.current,
      size: pagination.pageSize,
      ...searchForm
    },
    {
      onSuccess: (data) => {
        courseList.value = data.records || []
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
  router.push(`/course/${id}`)
}

// 页面加载
onMounted(() => {
  loadData()
})
</script>

<style scoped>
.course-spotlight-wrap { width:calc(100% - 96px); max-width:1200px; margin:0 auto 45px; }
@media(max-width:600px) { .course-spotlight-wrap { width:calc(100% - 40px); margin-bottom:30px; } }

.collection-heading { max-width: 1280px; width: calc(100% - 96px); margin: 56px auto 25px; display: flex; align-items: flex-end; justify-content: space-between; gap: 24px; }
.section-kicker, .course-kicker { font: 10px/1.6 Arial,sans-serif; color: #aa8e66; letter-spacing: .18em; }
.collection-heading h2 { margin: 12px 0 0; font: 400 29px/1.5 'Songti SC','SimSun',serif; letter-spacing: .1em; color: #34372f; }
.collection-heading p { margin: 0 0 4px; font-size: 12px; color: #8f8371; white-space: nowrap; }.collection-heading strong { font: 27px Georgia,serif; color: #a03328; padding: 0 5px; }
.search-section { width: calc(100% - 96px); max-width: 1280px; margin: 0 auto 38px; padding: 24px 0; border-top: 1px solid #cfc3af; border-bottom: 1px solid #cfc3af; }
.search-section :deep(.ant-input-affix-wrapper),.search-section :deep(.ant-select-selector),.search-section :deep(.ant-input) { border-radius: 0; min-height: 40px; background: #fbf8f1; border-color: #d7cdbb; }.search-section :deep(.ant-input-affix-wrapper .ant-input) { min-height: auto; }.search-section :deep(.ant-select-selector) { display: flex; align-items: center; }.search-section :deep(.ant-btn) { height: 40px; border-radius: 0; letter-spacing: .15em; }.search-section :deep(.ant-btn-primary) { background: #9f3026; border-color: #9f3026; }.search-section :deep(.ant-btn-primary:hover) { background: #7f211a; border-color: #7f211a; }
.pagination-section { max-width: 1280px; margin: 0 auto; padding: 40px 0 64px; display: flex; justify-content: center; }.pagination-section :deep(.ant-pagination-item) { border-radius: 0; }.pagination-section :deep(.ant-pagination-item-active) { border-color: #9f3026; background: #9f3026; }.pagination-section :deep(.ant-pagination-item-active a) { color: #fff; }
@media(max-width:760px) { .collection-heading,.search-section { width: calc(100% - 44px); }.collection-heading { margin-top: 35px; gap: 16px; }.collection-heading h2 { font-size: 22px; }.collection-heading p { font-size: 10px; }.collection-heading strong { font-size: 21px; }.section-kicker { font-size: 8px; }.search-section { padding: 18px 0; margin-bottom: 27px; }.pagination-section { padding: 30px 20px 45px; }.pagination-section :deep(.ant-pagination-options) { display: none; } }

.course-list { min-height: 100vh; background: #f7f4ec; padding-bottom: 5px; }.course-grid { max-width: 1280px; width: calc(100% - 96px); min-height: 360px; margin: auto; }.course-grid :deep(.ant-col) { display: flex; }
.course-card { width: 100%; background: #fdfbf5; border: 1px solid #d5cab8; display: flex; flex-direction: column; overflow: hidden; cursor: pointer; transition: transform .35s,box-shadow .35s; }.course-card:hover { transform: translateY(-5px); box-shadow: 0 12px 22px #433a2912; }.course-card:focus-visible { outline: 2px solid #9f3026; outline-offset: 4px; }
.course-cover { height: 230px; position: relative; overflow: hidden; }.course-cover:after { content: ''; position: absolute; inset: 0; background: linear-gradient(0deg,#101a15a8,transparent 55%); pointer-events: none; }.course-cover img { width: 100%; height: 100%; object-fit: cover; display: block; transition: transform .65s; }.course-card:hover img { transform: scale(1.055); }.cover-label { position: absolute; z-index: 1; bottom: 17px; left: 22px; font-size: 11px; color: #fff3d8; letter-spacing: .08em; }.cover-label i { margin-right: 6px; font-size: 15px; }
.course-content { padding: 24px; flex: 1; display: flex; flex-direction: column; }.course-kicker { display: block; margin-bottom: 15px; font-size: 8px; letter-spacing: .12em; }.course-header-row { display: flex; align-items: flex-start; gap: 12px; padding-bottom: 20px; margin-bottom: 20px; border-bottom: 1px solid #e0d5c1; }.course-title { flex: 1; font: 400 21px/1.65 'Songti SC','SimSun',serif; letter-spacing: .05em; color: #34372f; margin: 0; }.course-header-row :deep(.ant-tag) { flex-shrink: 0; border-radius: 0; writing-mode: vertical-rl; padding: 5px 3px; font-size: 10px; color: #94503b; background: transparent; border-color: #c5aa8f; margin: 4px 0 0; }
.course-meta { flex: 1; display: flex; gap: 24px; padding-bottom: 22px; }.meta-item { color: #9a8b73; font-size: 11px; display: flex; gap: 8px; align-items: center; }.meta-item i { color: #a08c6d; }.course-action :deep(.ant-btn) { display: flex; align-items: center; justify-content: space-between; height: 35px; width: 100%; color: #874332; background: transparent; border: 0; border-top: 1px solid #d6c7ac; border-radius: 0; padding: 15px 0 0; font-size: 12px; letter-spacing: .1em; box-shadow: none; }.course-action :deep(.ant-btn:hover) { color: #a02e25; border-color: #a02e25; }
@media(max-width:1100px) { .course-cover { height: 205px; }.course-title { font-size: 18px; }.course-content { padding: 21px; } }
@media(max-width:760px) { .course-grid { width: calc(100% - 44px); }.course-cover { height: 235px; }.course-title { font-size: 21px; }.course-content { padding: 23px; } }

</style>
