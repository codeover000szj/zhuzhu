<template>
  <div class="course-detail">
    <a-spin :spinning="loading">
      <div
        v-if="course"
        class="detail-container"
      >
        <nav
          class="detail-breadcrumb"
          aria-label="当前位置"
        >
          <router-link to="/home">
            首页
          </router-link><span>/</span><router-link to="/course">
            在线课堂
          </router-link><span>/</span><span>课程详情</span>
        </nav>
        <!-- 课程头部 -->
        <div class="course-header">
          <div class="header-content">
            <span class="detail-kicker">THE ONLINE ACADEMY / 非遗传习</span>
            <h1>{{ course.title }}</h1>
            <div class="course-tags">
              <a-tag :color="getCourseLevelColor(course.level)">
                {{ getCourseLevelName(course.level) }}
              </a-tag>
              <a-tag color="green">
                {{ course.statusName }}
              </a-tag>
            </div>
            <div class="course-stats">
              <span><i class="fas fa-book" /> {{ chapters.length }} 章节</span>
            </div>
          </div>
          <div class="header-art">
            <img
              :src="courseMedia.cover"
              :alt="courseMedia.coverAlt"
            ><span>习艺<br>传心</span>
          </div>
        </div>

        <!-- 课程内容 -->
        <div class="course-body">
          <a-row :gutter="32">
            <a-col
              :xs="24"
              :lg="16"
            >
              <!-- 课程简介 -->
              <div class="info-section">
                <h2>
                  <i class="fas fa-info-circle" /> 课程简介
                </h2>
                <div class="course-description">
                  {{ course.description || '暂无课程简介' }}
                </div>
              </div>

              <!-- 课程章节 -->
              <div class="info-section">
                <h2>
                  <i class="fas fa-list" /> 课程目录
                </h2>
                <div class="chapter-list">
                  <div
                    v-for="(chapter, index) in chapters"
                    :key="chapter.id"
                    class="chapter-item"
                    :class="{ completed: isChapterCompleted(chapter.id) }"
                    role="button"
                    tabindex="0"
                    @click="playChapter(chapter)"
                    @keydown.enter.self="playChapter(chapter)"
                  >
                    <div class="chapter-number">
                      {{ index + 1 }}
                    </div>
                    <div class="chapter-info">
                      <h4>{{ chapter.title }}</h4>
                      <p v-if="chapter.content">
                        {{ chapter.content.substring(0, 60) }}...
                      </p>
                    </div>
                    <div class="chapter-icon">
                      <i
                        v-if="isChapterCompleted(chapter.id)"
                        class="fas fa-circle-check"
                      />
                      <i
                        v-else-if="chapter.videoFiles && chapter.videoFiles.length > 0"
                        class="fas fa-play-circle"
                      />
                      <i
                        v-else
                        class="fas fa-file-alt"
                      />
                    </div>
                  </div>
                  <a-empty
                    v-if="chapters.length === 0"
                    description="暂无章节"
                  />
                </div>
              </div>
            </a-col>

            <a-col
              :xs="24"
              :lg="8"
            >
              <!-- 学习卡片 -->
              <div class="learning-card">
                <div class="card-cover">
                  <img
                    :src="courseMedia.cover"
                    :alt="courseMedia.coverAlt"
                  >
                </div>
                <div class="card-content">
                  <a
                    v-if="courseMedia.videoUrl"
                    class="video-course-link"
                    :href="courseMedia.videoUrl"
                    target="_blank"
                    rel="noopener noreferrer"
                    @click.stop
                  >
                    <i class="fas fa-circle-play" />
                    <span>观看{{ courseMedia.videoTitle }}视频</span>
                    <i class="fas fa-arrow-up-right-from-square" />
                  </a>
                  <a-button
                    v-if="course.status === 1"
                    type="primary"
                    size="large"
                    block
                    @click="startLearning"
                  >
                    {{ courseState.enrolled ? '继续学习' : '加入学习' }}
                  </a-button>
                  <a-button
                    v-else
                    size="large"
                    block
                    disabled
                  >
                    课程暂未开放
                  </a-button>
                  <a-button
                    v-if="courseState.enrolled"
                    block
                    class="progress-link"
                    @click="router.push('/learning')"
                  >
                    查看学习任务与进度
                  </a-button>

                  <div class="learning-tips">
                    <h4>学习须知</h4>
                    <ul>
                      <li>课程章节按顺序学习效果更佳</li>
                      <li>建议准备好笔记本记录重点</li>
                      <li>遇到问题可在线咨询老师</li>
                      <li>完成章节后可在学习中心查看进度</li>
                    </ul>
                  </div>
                </div>
              </div>
            </a-col>
          </a-row>
        </div>
      </div>
    </a-spin>

    <!-- 章节详情弹窗 -->
    <a-modal
      v-model:open="isChapterModalVisible"
      :title="currentChapter?.title"
      width="800px"
      :footer="null"
    >
      <div class="chapter-detail">
        <!-- 视频播放区域 -->
        <div
          v-if="currentChapter?.videoFiles && currentChapter.videoFiles.length > 0"
          class="chapter-video"
        >
          <video
            v-for="(video, index) in currentChapter.videoFiles"
            :key="video.id"
            :src="getVideoUrl(video.filePath)"
            controls
            preload="metadata"
            class="video-player"
            :class="{ 'mb-16': index < currentChapter.videoFiles.length - 1 }"
          >
            <p>您的浏览器不支持视频播放，请升级浏览器或使用其他浏览器。</p>
          </video>
        </div>
        
        <!-- 无视频时的提示 -->
        <div
          v-else
          class="no-video-tip"
        >
          <i class="fas fa-file-text" />
          <p>本章节提供文字学习导读，请结合下方内容完成学习记录</p>
        </div>
        
        <!-- 章节文字内容 -->
        <div class="chapter-content">
          <h3>章节内容</h3>
          <div class="content-text">
            {{ currentChapter?.content || '暂无文字内容' }}
          </div>
          <div class="chapter-resources">
            <h3><i class="fas fa-book-open" /> 本章学习资料</h3>
            <div class="resource-links">
              <a
                v-if="courseMedia.videoUrl"
                :href="courseMedia.videoUrl"
                target="_blank"
                rel="noopener noreferrer"
              >
                <i class="fas fa-circle-play" />
                观看对应课程视频
              </a>
              <a
                :href="getChapterResearchUrl(course?.title, currentChapter?.title)"
                target="_blank"
                rel="noopener noreferrer"
              >
                <i class="fas fa-magnifying-glass" />
                查看本章中国非遗网资料
              </a>
            </div>
          </div>
          <div
            v-if="courseState.enrolled"
            class="chapter-complete"
          >
            <a-button
              v-if="!isChapterCompleted(currentChapter?.id)"
              type="primary"
              @click="markChapterComplete"
            >
              <template #icon>
                <i class="fas fa-check" />
              </template>
              标记本章已完成
            </a-button>
            <a-tag
              v-else
              color="green"
            >
              本章已完成
            </a-tag>
          </div>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { getCourseDetail, getCourseChapters } from '@/api/CourseApi'
import { completeChapter, enrollCourse, getCourseStatus } from '@/api/learning'
import { useUserStore } from '@/store/user'
import { getCourseLevelName, getCourseLevelColor } from '@/config/courseLevel'
import { getCourseMedia, getChapterResearchUrl } from '@/config/heritageMedia'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const course = ref(null)
const chapters = ref([])
const loading = ref(false)
const isChapterModalVisible = ref(false)
const currentChapter = ref(null)
const courseState = ref({ enrolled: false, completedChapterIds: [], canManage: false })
const completedIds = computed(() => new Set((courseState.value.completedChapterIds || []).map(Number)))
const courseMedia = computed(() => getCourseMedia(course.value?.title))

const isChapterCompleted = (chapterId) => completedIds.value.has(Number(chapterId))

// 加载课程详情
const loadDetail = () => {
  loading.value = true
  getCourseDetail(
    { courseId: route.params.id },
    {
      onSuccess: (data) => {
        course.value = data
        if (data.chapters && data.chapters.length > 0) {
          chapters.value = data.chapters
        } else {
          loadChapters()
        }
        loadCourseState()
        loading.value = false
      },
      onError: () => {
        loading.value = false
        message.error('加载失败')
        router.back()
      }
    }
  )
}

const loadCourseState = async () => {
  if (!userStore.isLoggedIn) return
  try {
    courseState.value = await getCourseStatus(route.params.id)
  } catch {
    courseState.value = { enrolled: false, completedChapterIds: [], canManage: false }
  }
}

// 加载章节列表
const loadChapters = () => {
  getCourseChapters(
    { courseId: route.params.id },
    {
      onSuccess: (data) => {
        chapters.value = data || []
      }
    }
  )
}

// 开始学习
const startLearning = async () => {
  if (!userStore.isLoggedIn) {
    router.push({ path: '/auth/login', query: { redirect: route.fullPath } })
    return
  }
  try {
    if (!courseState.value.enrolled) {
      courseState.value = await enrollCourse(route.params.id)
      message.success('已加入课程，学习进度会自动保存')
    }
  if (chapters.value.length > 0) {
      playChapter(chapters.value.find(chapter => !isChapterCompleted(chapter.id)) || chapters.value[0])
  } else {
    message.info('暂无章节内容')
  }
  } catch (error) {
    message.error(error.message || '加入课程失败')
  }
}

// 播放章节
const playChapter = (chapter) => {
  currentChapter.value = chapter
  isChapterModalVisible.value = true
}

const markChapterComplete = async () => {
  if (!currentChapter.value) return
  try {
    await completeChapter(route.params.id, currentChapter.value.id)
    courseState.value.completedChapterIds = [...courseState.value.completedChapterIds, currentChapter.value.id]
    message.success('章节进度已记录')
  } catch (error) {
    message.error(error.message || '进度记录失败')
  }
}

// 工具函数
const getVideoUrl = (filePath) => {
  if (!filePath) return ''
  if (filePath.startsWith('http')) return filePath
  // 静态资源直接访问，不需要API前缀
  return filePath.startsWith('/') ? filePath : '/' + filePath
}

onMounted(() => {
  loadDetail()
})
</script>

<style scoped>

.detail-breadcrumb { display: flex; gap: 13px; align-items: center; padding: 29px 0; font-size: 11px; color: #a39783; }.detail-breadcrumb a { color: #8b7c63; }.detail-breadcrumb a:hover { color: #9f3026; }.detail-breadcrumb span:last-child { color: #3c4e43; }
.detail-kicker { display: block; color: #b09369; font: 9px/1.8 Arial,sans-serif; letter-spacing: .17em; margin-bottom: 18px; }
@media(max-width:760px) { .detail-breadcrumb { padding: 22px 0; font-size: 10px; gap: 10px; } }

.course-detail { min-height: 100vh; padding: 0 48px 70px; color: #3b3b31; background: #f7f4ec; }.detail-container { max-width: 1280px; margin: auto; }.course-header { display: grid; grid-template-columns: 1.4fr 1fr; background: #2b4238; color: #fff5dd; min-height: 320px; overflow: hidden; position: relative; }.header-content { position: relative; padding: 49px 52px; display: flex; flex-direction: column; justify-content: center; z-index: 1; background-image: repeating-linear-gradient(90deg,#ffffff03 0 1px,transparent 1px 4px); }.header-content:after { position: absolute; content: ''; inset: 12px; border: 1px solid #b9ac8d33; pointer-events: none; }.header-content h1 { font: 400 34px/1.65 'Songti SC','SimSun',serif; color: #fff7e3; letter-spacing: .1em; margin: 0 0 24px; }.course-tags { margin-bottom: 18px; }.course-tags :deep(.ant-tag) { border-radius: 0; color: #e0c294; background: transparent; border-color: #cbbd9c66; font-size: 11px; padding: 3px 9px; }.course-stats { color: #c9c7b5; font-size: 11px; letter-spacing: .05em; }.course-stats i { color: #d0b27d; margin-right: 6px; }.header-art { position: relative; min-height: 100%; overflow: hidden; }.header-art:after { content: ''; position: absolute; inset: 0; background: linear-gradient(90deg,#2b4238 0%,#2b423830 50%,#16241b33); }.header-art img { display: block; width: 100%; height: 100%; position: absolute; inset: 0; object-fit: cover; }.header-art>span { position: absolute; right: 28px; bottom: 27px; z-index: 1; color: #fff5dc; font: 25px/1.6 'Songti SC',serif; letter-spacing: .15em; border: 1px solid #ffffff8a; padding: 9px 13px; }
.course-body { padding-top: 40px; }.info-section { padding: 15px 18px 18px 0; margin-bottom: 29px; }.info-section h2 { display: flex; align-items: center; gap: 13px; font: 400 25px/1.5 'Songti SC','SimSun',serif; color: #3b4438; letter-spacing: .15em; border-bottom: 1px solid #d3c6ae; margin: 0 0 27px; padding-bottom: 18px; }.info-section h2 i { color: #a3825d; font-size: 17px; }.course-description { white-space: pre-wrap; text-align: justify; color: #7b725f; font-size: 14px; line-height: 2.2; }
.chapter-list { border-top: 1px solid #d9ceb9; }.chapter-item { display: flex; align-items: center; gap: 21px; padding: 24px 12px 24px 0; cursor: pointer; border-bottom: 1px solid #d9ceb9; transition: background .3s,padding .3s; }.chapter-item:hover { background: #eee8da; padding-left: 15px; }.chapter-item:focus-visible { outline: 2px solid #9f3026; outline-offset: 2px; }.chapter-number { flex-shrink: 0; font: 30px Georgia,serif; min-width: 45px; text-align: center; color: #b7a17a; }.chapter-info { flex: 1; min-width: 0; }.chapter-info h4 { margin: 0 0 8px; font: 400 20px/1.7 'Songti SC',serif; color: #42483a; }.chapter-info p { margin: 0; color: #978b76; font-size: 11px; line-height: 1.9; }.chapter-icon { font-size: 17px; color: #a08a61; }.chapter-item.completed .chapter-number,.chapter-item.completed .chapter-icon { color: #537962; }
.learning-card { border: 1px solid #d1c2a9; background: #fbf8f0; margin-top: 15px; position: sticky; top: 24px; }.card-cover { height: 220px; overflow: hidden; }.card-cover img { width: 100%; height: 100%; object-fit: cover; display: block; }.card-content { padding: 26px; }.video-course-link { display: flex; align-items: center; gap: 10px; padding-bottom: 20px; margin-bottom: 21px; border-bottom: 1px solid #d8cbb5; color: #526f59; font-size: 12px; line-height: 1.9; }.video-course-link span { flex: 1; }.video-course-link:hover { color: #a02e25; }.card-content :deep(.ant-btn) { height: 44px; border-radius: 0; letter-spacing: .1em; font-size: 13px; border-color: #cbbca1; }.card-content :deep(.ant-btn-primary) { background: #9f3026; border-color: #9f3026; color: #fff5e2; }.card-content :deep(.ant-btn-primary:hover) { background: #7c211b; border-color: #7c211b; }.progress-link { margin-top: 10px; }.learning-tips { border-top: 1px solid #dbceb9; padding-top: 22px; margin-top: 25px; }.learning-tips h4 { color: #53604c; font: 400 18px 'Songti SC',serif; letter-spacing: .1em; margin: 0 0 15px; }.learning-tips ul { padding: 0 0 0 15px; margin: 0; }.learning-tips li { color: #998b74; font-size: 11px; line-height: 2.25; padding-bottom: 4px; }
.chapter-detail { padding: 5px; }.chapter-video { margin-bottom: 24px; }.video-player { width: 100%; max-height: 420px; background: #1f2924; }.video-player.mb-16 { margin-bottom: 16px; }.no-video-tip { display: flex; align-items: center; gap: 14px; padding: 18px 22px; border-left: 3px solid #a58b5b; background: #eee9dd; margin: 10px 0 25px; }.no-video-tip>i { font-size: 23px; color: #a98c5f; }.no-video-tip p { margin: 0; color: #8e7d60; font-size: 12px; line-height: 1.8; }.chapter-content h3 { font: 400 20px/1.5 'Songti SC',serif; color: #43513f; border-bottom: 1px solid #d6c8ae; padding-bottom: 14px; margin: 0 0 20px; }.content-text { white-space: pre-wrap; text-align: justify; color: #786d59; line-height: 2.1; font-size: 14px; }.chapter-resources { border-top: 1px solid #e4d7bf; margin-top: 25px; padding-top: 24px; }.chapter-resources h3 { font-size: 18px; }.resource-links { display: flex; flex-wrap: wrap; gap: 13px 25px; }.resource-links a { font-size: 12px; color: #54705b; }.resource-links a i { margin-right: 6px; }.chapter-complete { margin-top: 25px; padding-top: 20px; border-top: 1px solid #e1d4be; }.chapter-complete :deep(.ant-btn) { border-radius: 0; background: #9f3026; border-color: #9f3026; }
@media(max-width:1100px) { .header-content { padding: 36px; }.header-content h1 { font-size: 29px; }.card-content { padding: 22px; }.card-cover { height: 185px; }.chapter-info h4 { font-size: 18px; } }
@media(max-width:991px) { .course-header { grid-template-columns: 1.4fr 1fr; min-height: 285px; }.header-content h1 { font-size: 27px; }.info-section { padding-right: 0; }.learning-card { position: static; display: grid; grid-template-columns: 1fr 1.3fr; margin: 15px 0 0; }.card-cover { height: 100%; min-height: 280px; }.course-body { padding-top: 27px; } }
@media(max-width:760px) { .course-detail { padding: 0 22px 45px; }.course-header { grid-template-columns: 1fr; }.header-content { padding: 35px 27px 32px; }.header-content h1 { font-size: 26px; line-height: 1.8; }.header-art { min-height: 200px; }.header-art:after { background: linear-gradient(180deg,#2b423855,transparent); }.header-art>span { right: 22px; bottom: 20px; font-size: 20px; }.course-description { font-size: 12px; line-height: 2.2; }.info-section h2 { font-size: 23px; }.chapter-item { gap: 13px; padding: 20px 6px 20px 0; }.chapter-number { min-width: 30px; font-size: 25px; }.chapter-info h4 { font-size: 17px; margin-bottom: 5px; }.chapter-info p { font-size: 10px; }.chapter-icon { font-size: 14px; }.learning-card { display: block; }.card-cover { height: 215px; min-height: unset; }.card-content { padding: 24px; }.content-text { font-size: 12px; }.no-video-tip { padding: 15px; gap: 12px; }.no-video-tip p { font-size: 11px; } }

</style>
