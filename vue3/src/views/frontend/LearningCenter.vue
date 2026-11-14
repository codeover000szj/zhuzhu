<template>
  <main class="learning-page">
    <PortalPageHeader eyebrow="MY LEARNING JOURNEY" title="学习 · 档案" description="让每一次练习留下痕迹，让每一次进步都有回响。" mark="传习" image="/images/hero-scene-5.jpg"><a-button @click="router.push('/course')">浏览全部课程 ↗</a-button></PortalPageHeader>
    <div class="studio-content">

    <div class="summary-strip">
      <div><strong>{{ courses.length }}</strong><span>已加入课程</span></div>
      <div><strong>{{ submittedCount }}</strong><span>已提交任务</span></div>
      <div><strong>{{ reviewedCount }}</strong><span>收到导师评阅</span></div>
    </div>

    <a-spin :spinning="loading">
      <a-empty v-if="!loading && !courses.length" description="还没有加入课程">
        <a-button type="primary" @click="router.push('/course')">前往选课</a-button>
      </a-empty>

      <section v-for="course in courses" :key="course.courseId" class="course-record">
        <div class="course-record-heading">
          <div>
            <p class="record-label">{{ course.level || '非遗课程' }} · {{ course.completedChapters || 0 }}/{{ course.totalChapters || 0 }} 章节</p>
            <h2>{{ course.title }}</h2>
          </div>
          <a-button @click="router.push(`/course/${course.courseId}`)">
            <template #icon><i class="fas fa-arrow-up-right-from-square"></i></template>
            继续学习
          </a-button>
        </div>
        <a-progress :percent="progress(course)" :show-info="false" :stroke-color="'#3c8068'" />

        <div class="task-area">
          <div class="task-area-heading">
            <h3>实践任务</h3>
            <span>{{ course.tasks?.length || 0 }} 项</span>
          </div>
          <a-empty v-if="!course.tasks?.length" description="课程暂未发布实践任务" :image="false" />
          <article v-for="task in course.tasks" :key="task.id" class="task-record">
            <div class="task-copy">
              <div class="task-title-row">
                <h4>{{ task.title }}</h4>
                <a-tag :color="task.submissionStatus === 1 ? 'green' : task.submissionStatus === 0 ? 'blue' : 'default'">
                  {{ task.submissionStatus === 1 ? `已评阅 · ${task.score ?? '-'} 分` : task.submissionStatus === 0 ? '待评阅' : '待提交' }}
                </a-tag>
              </div>
              <p>{{ task.description || '完成课程实践，并记录制作过程。' }}</p>
              <small v-if="task.dueAt">截止 {{ formatDate(task.dueAt) }}</small>
              <div v-if="task.feedback" class="feedback-line"><i class="fas fa-comment-dots"></i> {{ task.feedback }}</div>
            </div>
            <div class="task-submit">
              <a-textarea v-model:value="drafts[task.id].content" :rows="2" :maxlength="10000" placeholder="记录实践过程、遇到的问题或心得" />
              <a-input v-model:value="drafts[task.id].evidenceUrl" placeholder="作品图片 / 视频链接（选填）" />
              <a-button type="primary" size="small" :loading="submittingTask === task.id" @click="submitTask(course.courseId, task)">
                {{ task.submissionStatus === 0 || task.submissionStatus === 1 ? '更新提交' : '提交任务' }}
              </a-button>
            </div>
          </article>
        </div>
      </section>
    </a-spin>
    </div>
  </main>
</template>

<script setup>
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'
import { computed, onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { getMyCourses, getCourseTasks, submitCourseTask } from '@/api/learning'
import { withDisplayYear } from '@/utils/dateUtils'

const router = useRouter()
const loading = ref(false)
const submittingTask = ref(null)
const courses = ref([])
const drafts = reactive({})

const tasks = computed(() => courses.value.flatMap(course => course.tasks || []))
const submittedCount = computed(() => tasks.value.filter(task => task.submissionStatus === 0 || task.submissionStatus === 1).length)
const reviewedCount = computed(() => tasks.value.filter(task => task.submissionStatus === 1).length)

function progress(course) {
  const total = Number(course.totalChapters || 0)
  return total ? Math.round(Number(course.completedChapters || 0) * 100 / total) : 0
}

function formatDate(value) {
  const date = withDisplayYear(value)
  return date ? date.toLocaleDateString('zh-CN') : ''
}

async function load() {
  loading.value = true
  try {
    const records = await getMyCourses()
    courses.value = await Promise.all((records || []).map(async course => {
      const courseTasks = await getCourseTasks(course.courseId)
      for (const task of courseTasks || []) {
        if (!drafts[task.id]) drafts[task.id] = { content: '', evidenceUrl: '' }
      }
      return { ...course, tasks: courseTasks || [] }
    }))
  } catch (error) {
    message.error(error.message || '学习记录暂时无法加载')
  } finally {
    loading.value = false
  }
}

async function submitTask(courseId, task) {
  submittingTask.value = task.id
  try {
    await submitCourseTask(courseId, task.id, drafts[task.id])
    message.success('学习任务已提交')
    await load()
  } catch (error) {
    message.error(error.message || '提交失败')
  } finally {
    submittingTask.value = null
  }
}

onMounted(load)
</script>

<style scoped>
.learning-page { max-width: 1120px; margin: 0 auto; padding: 36px 24px 72px; color: #22342f; }
.page-heading { display: flex; justify-content: space-between; align-items: end; gap: 24px; padding-bottom: 26px; border-bottom: 1px solid #dce5df; }
.kicker, .record-label { margin: 0 0 8px; color: #668276; font-size: 12px; font-weight: 700; }
h1 { margin: 0; font-size: 32px; color: #203b32; }
.lede { margin: 10px 0 0; color: #687a73; }
.summary-strip { display: grid; grid-template-columns: repeat(3, 1fr); border-bottom: 1px solid #dce5df; padding: 20px 0; margin-bottom: 10px; }
.summary-strip > div { display: flex; align-items: baseline; gap: 12px; border-right: 1px solid #dce5df; padding-left: 20px; }
.summary-strip > div:first-child { padding-left: 0; }
.summary-strip > div:last-child { border-right: 0; }
.summary-strip strong { color: #34745e; font-size: 24px; }
.summary-strip span { color: #728078; font-size: 13px; }
.course-record { padding: 26px 0 34px; border-bottom: 1px solid #dce5df; }
.course-record-heading { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 12px; }
.course-record h2 { margin: 0; font-size: 20px; }
.task-area { padding-top: 20px; }
.task-area-heading { display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #e6ece8; padding-bottom: 10px; }
.task-area-heading h3 { margin: 0; font-size: 16px; }
.task-area-heading span, .task-copy small { color: #819089; font-size: 12px; }
.task-record { display: grid; grid-template-columns: minmax(220px, 1fr) minmax(260px, 390px); gap: 26px; padding: 18px 0; border-bottom: 1px solid #edf1ee; }
.task-title-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.task-title-row h4 { margin: 0; font-size: 15px; }
.task-copy p { margin: 8px 0; color: #66766f; line-height: 1.65; white-space: pre-wrap; }
.feedback-line { margin-top: 10px; color: #9b5d31; font-size: 13px; }
.task-submit { display: grid; grid-template-columns: 1fr auto; gap: 8px; align-content: start; }
.task-submit :deep(.ant-input-textarea) { grid-column: 1 / -1; }
.task-submit :deep(.ant-input) { min-width: 0; }
@media (max-width: 720px) {
  .learning-page { padding: 24px 16px 52px; }
  .page-heading { align-items: start; flex-direction: column; }
  h1 { font-size: 26px; }
  .summary-strip > div { flex-direction: column; gap: 2px; padding-left: 10px; }
  .task-record { grid-template-columns: 1fr; gap: 12px; }
  .course-record-heading { align-items: start; }
}

/* 与全站文化门户统一的工作空间 */
.learning-page { max-width:none; padding:0; color:#37382f; }
.studio-content { width:min(1240px,calc(100% - 96px)); margin:auto; padding:38px 0 75px; }
.summary-strip { margin:0 0 26px; padding:27px 31px; border:1px solid #d4c6af; background:#e9e4d7; }.summary-strip>div { border-color:#d0c3ad; }.summary-strip strong { font:38px Georgia,serif; color:#91663f; }.summary-strip span { color:#91816a; font-size:11px; }.course-record { padding:29px 31px 32px; border:1px solid #d8cdb9; margin-bottom:28px; background:#fffdf66b; border-top:3px solid #8a7455; }.course-record-heading { padding-bottom:15px; }.record-label { color:#a18a67; font-size:10px; letter-spacing:.08em; font-weight:400; }.course-record h2 { font-size:24px; font-weight:400; letter-spacing:.06em; }.task-area-heading { border-color:#d9ccb7; padding-bottom:18px; }.task-area-heading h3 { font:400 19px 'Songti SC',serif; }.task-record { padding-block:24px; border-color:#e1d8c9; }.task-title-row h4 { font-size:17px; font-weight:500; }.task-copy p { font-size:12px; color:#8d8473; line-height:1.9; }.feedback-line { padding:12px; background:#ece7db; border-left:2px solid #ab8760; color:#90633e; font-size:12px; }
@media(max-width:760px) { .studio-content { width:calc(100% - 44px); padding:25px 0 50px; }.summary-strip { padding:22px 15px; }.summary-strip strong { font-size:30px; }.summary-strip span { font-size:9px; }.course-record { padding:23px 17px; }.course-record h2 { font-size:21px; }.course-record-heading { align-items:start; flex-direction:column; }.work-section { padding-inline:15px; }.workspace-stats strong { font-size:30px; }.course-bar { padding:18px; } }
</style>
