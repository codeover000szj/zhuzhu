<template>
  <main class="teacher-page">
    <PortalPageHeader eyebrow="THE HERITAGE TEACHING STUDIO" title="传习 · 工作台" description="把一门手艺的经验，整理成可以循序学习的知识。" mark="师者" image="/images/hero-scene-4.jpg"><a-button @click="courseModalOpen = true">新建课程 ＋</a-button></PortalPageHeader>
    <div class="studio-content">

    <div v-if="courses.length" class="course-bar">
      <label for="course-select">当前课程</label>
      <a-select id="course-select" v-model:value="selectedCourseId" class="course-select" @change="loadCourseData">
        <a-select-option v-for="course in courses" :key="course.id" :value="course.id">
          {{ course.title }} · {{ statusName(course.status) }}
        </a-select-option>
      </a-select>
      <a-tag :color="currentCourse?.status === 1 ? 'green' : 'orange'">{{ currentCourse ? statusName(currentCourse.status) : '' }}</a-tag>
      <span v-if="currentCourse?.status === 0" class="approval-note">课程发布前需由管理员审核</span>
    </div>

    <a-empty v-if="!loading && !courses.length" description="还没有负责的课程">
      <a-button type="primary" @click="courseModalOpen = true">创建第一门课程</a-button>
    </a-empty>

    <a-spin :spinning="loading">
      <template v-if="currentCourse">
        <div class="workspace-stats">
          <div><strong>{{ currentCourse.chapterCount || 0 }}</strong><span>课程章节</span></div>
          <div><strong>{{ resources.length }}</strong><span>教学资源</span></div>
          <div><strong>{{ tasks.length }}</strong><span>学习任务</span></div>
          <div><strong>{{ pendingCount }}</strong><span>待评阅作业</span></div>
        </div>

        <a-tabs v-model:activeKey="activeTab" class="workspace-tabs">
          <a-tab-pane key="resources" tab="教学资源">
            <section class="work-section">
              <div class="section-heading">
                <div><p class="section-kicker">RESOURCE LIBRARY</p><h2>课程资料</h2></div>
                <a-button @click="resourceModalOpen = true"><template #icon><i class="fas fa-paperclip"></i></template>添加资源</a-button>
              </div>
              <a-empty v-if="!resources.length" description="暂无教学资源" />
              <div v-for="resource in resources" :key="resource.id" class="resource-row">
                <div class="resource-mark"><i :class="resourceIcon(resource.resourceType)"></i></div>
                <div class="resource-copy">
                  <strong>{{ resource.title }}</strong>
                  <span>{{ resource.resourceType }} · {{ resource.description || '课程补充资料' }}</span>
                </div>
                <a :href="resource.resourceUrl" target="_blank" rel="noreferrer" class="resource-open">打开 <i class="fas fa-arrow-up-right-from-square"></i></a>
                <a-popconfirm title="移除此资源？" @confirm="removeResource(resource.id)">
                  <a-button type="text" danger aria-label="删除资源"><i class="fas fa-trash"></i></a-button>
                </a-popconfirm>
              </div>
            </section>
          </a-tab-pane>

          <a-tab-pane key="tasks" tab="学习任务">
            <section class="work-section">
              <div class="section-heading">
                <div><p class="section-kicker">PRACTICE / FEEDBACK</p><h2>布置实践与评阅</h2></div>
              </div>
              <a-form layout="vertical" :model="taskForm" class="task-create-form" @finish="publishTask">
                <a-form-item label="任务名称" name="title" :rules="[{ required: true, message: '请填写任务名称' }]">
                  <a-input v-model:value="taskForm.title" :maxlength="160" placeholder="例如：完成一段平针练习" />
                </a-form-item>
                <a-form-item label="实践要求">
                  <a-textarea v-model:value="taskForm.description" :rows="3" :maxlength="5000" placeholder="写清楚提交内容、观察重点与评价标准" />
                </a-form-item>
                <a-form-item label="截止时间">
                  <input v-model="taskForm.dueAt" class="date-input" type="datetime-local" />
                </a-form-item>
                <a-button type="primary" html-type="submit" :loading="savingTask">发布任务</a-button>
              </a-form>

              <div class="task-review-heading">
                <h3>任务提交与评阅</h3>
                <a-select v-model:value="selectedTaskId" :disabled="!tasks.length" placeholder="选择任务查看提交" class="task-select" @change="loadSubmissions">
                  <a-select-option v-for="task in tasks" :key="task.id" :value="task.id">{{ task.title }}</a-select-option>
                </a-select>
              </div>
              <a-empty v-if="selectedTaskId && !submissions.length" description="该任务还没有提交" />
              <article v-for="submission in submissions" :key="submission.id" class="submission-row">
                <div class="submission-copy">
                  <div class="submission-author"><strong>{{ submission.userName }}</strong><a-tag :color="submission.status === 1 ? 'green' : 'orange'">{{ submission.status === 1 ? '已评阅' : '待评阅' }}</a-tag></div>
                  <p>{{ submission.content || '未附文字记录' }}</p>
                  <a v-if="submission.evidenceUrl" :href="submission.evidenceUrl" target="_blank" rel="noreferrer">查看学习成果</a>
                  <div v-if="submission.status === 1" class="existing-feedback">{{ submission.score }} 分 · {{ submission.feedback }}</div>
                </div>
                <div class="review-controls">
                  <a-input-number v-model:value="reviewDrafts[submission.id].score" :min="0" :max="100" :precision="0" addon-after="分" />
                  <a-textarea v-model:value="reviewDrafts[submission.id].feedback" :rows="2" :maxlength="5000" placeholder="评语与下一步建议" />
                  <a-button type="primary" size="small" :loading="reviewingId === submission.id" @click="saveReview(submission)">保存评阅</a-button>
                </div>
              </article>
            </section>
          </a-tab-pane>
        </a-tabs>
      </template>
    </a-spin>

    <a-modal v-model:open="courseModalOpen" title="新建课程" :confirm-loading="savingCourse" @ok="createCourseRecord">
      <a-form layout="vertical" :model="courseForm">
        <a-form-item label="课程名称" required><a-input v-model:value="courseForm.title" :maxlength="200" /></a-form-item>
        <a-form-item label="学习级别"><a-select v-model:value="courseForm.level"><a-select-option value="beginner">入门</a-select-option><a-select-option value="intermediate">进阶</a-select-option><a-select-option value="advanced">研修</a-select-option></a-select></a-form-item>
        <a-form-item label="课程简介"><a-textarea v-model:value="courseForm.description" :rows="4" /></a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="resourceModalOpen" title="添加课程资源" :confirm-loading="savingResource" @ok="saveResource">
      <a-form layout="vertical" :model="resourceForm">
        <a-form-item label="资源名称" required><a-input v-model:value="resourceForm.title" :maxlength="160" /></a-form-item>
        <a-form-item label="资源类型"><a-select v-model:value="resourceForm.resourceType"><a-select-option value="LINK">网页链接</a-select-option><a-select-option value="VIDEO">视频</a-select-option><a-select-option value="DOCUMENT">文档</a-select-option></a-select></a-form-item>
        <a-form-item label="资源地址" required><a-input v-model:value="resourceForm.resourceUrl" placeholder="https://... 或 /files/..." /></a-form-item>
        <a-form-item label="说明"><a-input v-model:value="resourceForm.description" :maxlength="500" /></a-form-item>
      </a-form>
    </a-modal>
    </div>
  </main>
</template>

<script setup>
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'
import { computed, onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import { createCourse } from '@/api/CourseApi'
import {
  createCourseResource, createCourseTask, deleteCourseResource, getCourseResources,
  getCourseTasks, getTaskSubmissions, getTeacherCourses, reviewSubmission
} from '@/api/learning'

const loading = ref(false)
const courses = ref([])
const selectedCourseId = ref()
const currentCourse = computed(() => courses.value.find(course => course.id === selectedCourseId.value))
const resources = ref([])
const tasks = ref([])
const submissions = ref([])
const selectedTaskId = ref()
const activeTab = ref('resources')
const pendingCount = computed(() => submissions.value.filter(item => item.status === 0).length)
const courseModalOpen = ref(false)
const resourceModalOpen = ref(false)
const savingCourse = ref(false)
const savingResource = ref(false)
const savingTask = ref(false)
const reviewingId = ref(null)
const reviewDrafts = reactive({})
const courseForm = reactive({ title: '', level: 'beginner', description: '' })
const resourceForm = reactive({ title: '', resourceType: 'LINK', resourceUrl: '', description: '' })
const taskForm = reactive({ title: '', description: '', dueAt: '' })

function statusName(status) {
  return status === 1 ? '已發布' : status === 2 ? '已下架' : '待審核'
}

function resourceIcon(type) {
  return type === 'VIDEO' ? 'fas fa-circle-play' : type === 'DOCUMENT' ? 'fas fa-file-lines' : 'fas fa-link'
}

async function loadCourses() {
  loading.value = true
  try {
    courses.value = await getTeacherCourses() || []
    if (!courses.value.some(course => course.id === selectedCourseId.value)) selectedCourseId.value = courses.value[0]?.id
    if (selectedCourseId.value) await loadCourseData()
  } catch (error) {
    message.error(error.message || '工作区暂时无法加载')
  } finally {
    loading.value = false
  }
}

async function loadCourseData() {
  if (!selectedCourseId.value) return
  try {
    const [resourceList, taskList] = await Promise.all([
      getCourseResources(selectedCourseId.value),
      getCourseTasks(selectedCourseId.value)
    ])
    resources.value = resourceList || []
    tasks.value = taskList || []
    if (!tasks.value.some(task => task.id === selectedTaskId.value)) selectedTaskId.value = tasks.value[0]?.id
    await loadSubmissions()
  } catch (error) {
    message.error(error.message || '课程内容暂时无法加载')
  }
}

async function createCourseRecord() {
  if (!courseForm.title.trim()) {
    message.warning('请填写课程名称')
    return
  }
  savingCourse.value = true
  try {
    await createCourse({ id: crypto.randomUUID(), ...courseForm, status: 0 })
    message.success('课程草稿已创建，提交管理员审核后即可开放学习')
    courseModalOpen.value = false
    Object.assign(courseForm, { title: '', level: 'beginner', description: '' })
    await loadCourses()
  } catch (error) {
    message.error(error.message || '课程创建失败')
  } finally {
    savingCourse.value = false
  }
}

async function saveResource() {
  if (!selectedCourseId.value || !resourceForm.title.trim() || !resourceForm.resourceUrl.trim()) {
    message.warning('请填写资源名称和地址')
    return
  }
  savingResource.value = true
  try {
    await createCourseResource(selectedCourseId.value, resourceForm)
    message.success('资源已加入课程资料')
    resourceModalOpen.value = false
    Object.assign(resourceForm, { title: '', resourceType: 'LINK', resourceUrl: '', description: '' })
    await loadCourseData()
  } catch (error) {
    message.error(error.message || '资源保存失败')
  } finally {
    savingResource.value = false
  }
}

async function removeResource(resourceId) {
  try {
    await deleteCourseResource(resourceId)
    await loadCourseData()
  } catch (error) {
    message.error(error.message || '资源删除失败')
  }
}

async function publishTask() {
  if (!selectedCourseId.value) return
  savingTask.value = true
  try {
    await createCourseTask(selectedCourseId.value, taskForm)
    message.success('学习任务已发布')
    Object.assign(taskForm, { title: '', description: '', dueAt: '' })
    await loadCourseData()
    activeTab.value = 'tasks'
  } catch (error) {
    message.error(error.message || '任务发布失败')
  } finally {
    savingTask.value = false
  }
}

async function loadSubmissions() {
  if (!selectedTaskId.value) {
    submissions.value = []
    return
  }
  try {
    submissions.value = await getTaskSubmissions(selectedTaskId.value) || []
    for (const item of submissions.value) {
      if (!reviewDrafts[item.id]) reviewDrafts[item.id] = { score: item.score ?? 90, feedback: item.feedback || '' }
    }
  } catch (error) {
    message.error(error.message || '提交记录暂时无法加载')
  }
}

async function saveReview(submission) {
  const draft = reviewDrafts[submission.id]
  if (!draft.feedback.trim()) {
    message.warning('请填写评语或下一步建议')
    return
  }
  reviewingId.value = submission.id
  try {
    await reviewSubmission(submission.id, draft)
    message.success('评阅已保存')
    await loadSubmissions()
  } catch (error) {
    message.error(error.message || '评阅保存失败')
  } finally {
    reviewingId.value = null
  }
}

onMounted(loadCourses)
</script>

<style scoped>
.teacher-page { max-width: 1160px; margin: 0 auto; padding: 36px 24px 72px; color: #263830; }
.page-heading { display: flex; align-items: end; justify-content: space-between; gap: 20px; padding-bottom: 24px; border-bottom: 1px solid #dce5df; }
.kicker, .section-kicker { margin: 0 0 8px; color: #668276; font-size: 12px; font-weight: 700; }
h1 { margin: 0; color: #203b32; font-size: 30px; }
.course-bar { display: flex; align-items: center; gap: 14px; padding: 18px 0; border-bottom: 1px solid #dce5df; }
.course-bar label { color: #687a73; font-size: 13px; }
.course-select { min-width: 320px; max-width: 520px; }
.approval-note { color: #9b683e; font-size: 12px; }
.workspace-stats { display: grid; grid-template-columns: repeat(4, 1fr); padding: 18px 0; border-bottom: 1px solid #dce5df; }
.workspace-stats > div { display: flex; align-items: baseline; gap: 10px; border-right: 1px solid #dce5df; padding-left: 18px; }
.workspace-stats > div:first-child { padding-left: 0; }
.workspace-stats > div:last-child { border: 0; }
.workspace-stats strong { color: #34745e; font-size: 22px; }
.workspace-stats span { color: #728078; font-size: 13px; }
.workspace-tabs { margin-top: 10px; }
.work-section { padding: 8px 0 30px; }
.section-heading { display: flex; align-items: center; justify-content: space-between; padding: 18px 0; }
.section-heading h2 { margin: 0; font-size: 20px; }
.resource-row { display: flex; align-items: center; gap: 14px; padding: 14px 4px; border-top: 1px solid #e6ece8; }
.resource-mark { display: grid; place-items: center; width: 38px; height: 38px; border: 1px solid #cfddd4; color: #3c8068; }
.resource-copy { display: grid; gap: 5px; min-width: 0; flex: 1; }
.resource-copy strong { overflow-wrap: anywhere; }
.resource-copy span { color: #78877f; font-size: 12px; }
.resource-open { color: #34745e; white-space: nowrap; }
.task-create-form { display: grid; grid-template-columns: 1fr 1.5fr 220px auto; gap: 12px; align-items: end; padding: 10px 0 22px; border-bottom: 1px solid #dce5df; }
.task-create-form :deep(.ant-form-item) { margin-bottom: 0; }
.date-input { height: 32px; width: 100%; padding: 0 10px; border: 1px solid #d9d9d9; border-radius: 6px; color: #31443b; }
.task-review-heading { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 22px 0 10px; }
.task-review-heading h3 { margin: 0; font-size: 16px; }
.task-select { width: min(420px, 55%); }
.submission-row { display: grid; grid-template-columns: minmax(240px, 1fr) minmax(270px, 380px); gap: 26px; padding: 18px 0; border-top: 1px solid #e6ece8; }
.submission-author { display: flex; align-items: center; gap: 10px; }
.submission-copy p { margin: 9px 0; white-space: pre-wrap; line-height: 1.65; color: #586a61; }
.submission-copy a { color: #34745e; }
.existing-feedback { margin-top: 10px; color: #9b5d31; font-size: 13px; }
.review-controls { display: grid; grid-template-columns: 115px 1fr; gap: 8px; align-content: start; }
.review-controls :deep(.ant-input-textarea) { grid-column: 1 / -1; }
.review-controls :deep(.ant-btn) { grid-column: 2; justify-self: end; }
@media (max-width: 800px) {
  .teacher-page { padding: 24px 16px 52px; }
  .page-heading { align-items: start; flex-direction: column; }
  .course-bar { align-items: start; flex-direction: column; }
  .course-select { width: 100%; min-width: 0; }
  .workspace-stats { grid-template-columns: repeat(2, 1fr); row-gap: 14px; }
  .workspace-stats > div:nth-child(2) { border: 0; }
  .task-create-form { grid-template-columns: 1fr; }
  .submission-row { grid-template-columns: 1fr; gap: 14px; }
  .task-review-heading { align-items: start; flex-direction: column; }
  .task-select { width: 100%; }
}

/* 与全站文化门户统一的工作空间 */
.teacher-page { max-width:none; padding:0; color:#37382f; }
.studio-content { width:min(1240px,calc(100% - 96px)); margin:auto; padding:38px 0 75px; }
.course-bar { padding:22px 26px; background:#eae5d9; border:1px solid #d5c8b0; margin-bottom:28px; }.workspace-stats { padding:25px 0 30px; border-color:#d6c6ae; }.workspace-stats strong { font:36px Georgia,serif; color:#96724b; }.workspace-stats span { font-size:11px; color:#92836e; }.workspace-tabs { margin-top:24px; }.section-heading { padding:20px 0 25px; }.section-kicker { font:9px Arial,sans-serif; color:#ad9673; letter-spacing:.16em; }.section-heading h2 { font-size:25px; font-weight:400; letter-spacing:.1em; margin-top:9px; }.work-section { padding:4px 25px 30px; border:1px solid #dacdb7; background:#fffdf654; }.resource-row { padding:21px 0; border-color:#e0d5c3; }.resource-mark { color:#91734e; border-color:#cdbc9e; border-radius:0; }.resource-copy strong { font-weight:500; font-size:14px; }.resource-copy span { font-size:11px; color:#9d8e76; }.resource-open { color:#9a5440; font-size:12px; }.task-create-form { border-color:#d7c8af; }.submission-row { padding-block:24px; border-color:#d7c8af; }.submission-copy p { font-size:12px; color:#8b806e; }.date-input { border-radius:0; border-color:#d7c8af; }
@media(max-width:760px) { .studio-content { width:calc(100% - 44px); padding:25px 0 50px; }.summary-strip { padding:22px 15px; }.summary-strip strong { font-size:30px; }.summary-strip span { font-size:9px; }.course-record { padding:23px 17px; }.course-record h2 { font-size:21px; }.course-record-heading { align-items:start; flex-direction:column; }.work-section { padding-inline:15px; }.workspace-stats strong { font-size:30px; }.course-bar { padding:18px; } }
</style>
