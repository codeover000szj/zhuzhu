<template>
  <main class="community-page">
    <PortalPageHeader eyebrow="THE LIVING HERITAGE COMMUNITY" title="共学 · 答疑" description="一问一答之间，让经验流动，让手艺在共同学习中生长。" mark="共学" image="/images/hero-scene-4.jpg" />
    <div class="forum-shell">
      <div class="forum-main">
        <div class="forum-channel-bar"><span>共学现场 / COMMUNITY</span><a-select v-model:value="courseFilter" allow-clear placeholder="全部课程" class="course-filter" @change="loadQuestions"><a-select-option v-for="course in courseOptions" :key="course.id" :value="course.id">{{ course.title }}</a-select-option></a-select></div>
    <section v-if="userStore.isLoggedIn" class="compose-section">
      <a-form layout="vertical" :model="form" @finish="postQuestion">
        <a-row :gutter="16">
          <a-col :xs="24" :md="8">
            <a-form-item label="关联课程" name="courseId" :rules="[{ required: true, message: '请选择课程' }]">
              <a-select v-model:value="form.courseId" placeholder="选择讨论课程">
                <a-select-option v-for="course in courseOptions" :key="course.id" :value="course.id">{{ course.title }}</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="5">
            <a-form-item label="内容类型">
              <a-select v-model:value="form.kind">
                <a-select-option value="QUESTION">提问</a-select-option>
                <a-select-option value="COMMENT">交流</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :xs="24" :md="11">
            <a-form-item label="主题">
              <a-input v-model:value="form.title" :maxlength="160" :placeholder="form.kind === 'QUESTION' ? '一句话概括问题' : '讨论主题（选填）'" />
            </a-form-item>
          </a-col>
        </a-row>
        <a-form-item label="内容" name="content" :rules="[{ required: true, message: '请填写内容' }]">
          <a-textarea v-model:value="form.content" :rows="3" :maxlength="10000" show-count placeholder="描述遇到的步骤、材料或技法问题" />
        </a-form-item>
        <a-button type="primary" html-type="submit" :loading="posting">
          <template #icon><i class="fas fa-paper-plane"></i></template>
          发布讨论
        </a-button>
      </a-form>
    </section>
    <div v-else class="sign-in-line">
      <span>登录后可发布提问、评论与回复。</span>
      <a-button @click="router.push({ path: '/auth/login', query: { redirect: '/community' } })">登录</a-button>
    </div>

    <div class="discussion-toolbar">
      <h2>讨论串 <span class="discussion-count">{{ visibleQuestions.length }} / {{ questions.length }}</span></h2>
      <a-button type="text" :loading="loading" @click="loadQuestions"><i class="fas fa-rotate"></i></a-button>
    </div>
    <div class="discussion-filters">
      <a-input-search v-model:value="searchQuery" allow-clear placeholder="搜索主题、课程或内容" class="discussion-search" />
      <a-segmented v-model:value="viewMode" :options="viewOptions" />
    </div>
    <a-spin :spinning="loading">
      <a-empty v-if="!loading && !visibleQuestions.length" :description="questions.length ? '没有符合条件的讨论' : '还没有讨论，欢迎提出第一个问题'" />
      <article v-for="question in visibleQuestions" :key="question.id" class="discussion-item">
        <div class="discussion-meta">
          <a-tag :color="question.kind === 'QUESTION' ? 'volcano' : 'blue'">{{ question.kind === 'QUESTION' ? '提问' : '交流' }}</a-tag>
          <span>{{ question.courseTitle }}</span>
          <span>{{ question.userName }}</span>
          <time>{{ formatDate(question.createdAt) }}</time>
        </div>
        <h3>{{ question.title }}</h3>
        <p class="question-content">{{ question.content }}</p>
        <div v-if="question.replies?.length" class="reply-list">
          <div v-for="reply in question.replies" :key="reply.id" class="reply-item">
            <div class="reply-author">
              <strong>{{ reply.userName }}</strong>
              <a-tag v-if="reply.roleType === 'TEACHER' || reply.roleType === 'ADMIN'" color="green">官方答复</a-tag>
              <time>{{ formatDate(reply.createdAt) }}</time>
            </div>
            <p>{{ reply.content }}</p>
          </div>
        </div>
        <div class="discussion-footer">
          <span>{{ question.replies?.length || 0 }} 条回复</span>
          <span v-if="!question.replies?.length" class="unanswered-label">待解答</span>
        </div>
        <div v-if="userStore.isLoggedIn" class="reply-compose">
          <a-input v-model:value="replyDrafts[question.id]" placeholder="补充回复" @press-enter="sendReply(question.id)" />
          <a-button :loading="replyingId === question.id" @click="sendReply(question.id)">回复</a-button>
        </div>
      </article>
    </a-spin>
      </div>
      <aside class="forum-aside">
        <div class="forum-aside-intro"><HeritageKnot /><span>共同学习 · 共同传承</span><h2>让每个疑问<br />都有回响</h2><p>从一根丝线、一笔纹样到一道工序，分享你的观察与尝试。</p><div class="forum-counts"><div><strong>{{ questions.length }}</strong><span>讨论主题</span></div><div><strong>{{ courseOptions.length }}</strong><span>关联课程</span></div></div></div>
        <div class="forum-guide"><small>HOW TO JOIN</small><h3>共学约定</h3><p><b>01</b> 先说明课程与章节，方便找到同路人。</p><p><b>02</b> 描述材料、步骤与现象，让问题更具体。</p><p><b>03</b> 分享练习过程，也尊重每一次耐心解答。</p><router-link to="/course">寻找一门课程 <span>↗</span></router-link></div>
      </aside>
    </div>
  </main>
</template>

<script setup>
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'
import HeritageKnot from '@/components/frontend/HeritageKnot.vue'
import { computed, onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { getCoursePage } from '@/api/CourseApi'
import { createQuestion, getQuestions, replyToQuestion } from '@/api/learning'
import { withDisplayYear } from '@/utils/dateUtils'

const router = useRouter()
const userStore = useUserStore()
const courseOptions = ref([])
const courseFilter = ref()
const questions = ref([])
const searchQuery = ref('')
const viewMode = ref('latest')
const viewOptions = [
  { label: '最新', value: 'latest' },
  { label: '未解答', value: 'unanswered' },
  { label: '回复最多', value: 'active' }
]
const loading = ref(false)
const posting = ref(false)
const replyingId = ref(null)
const replyDrafts = reactive({})
const form = reactive({ courseId: undefined, kind: 'QUESTION', title: '', content: '' })

const visibleQuestions = computed(() => {
  const query = searchQuery.value.trim().toLocaleLowerCase()
  let result = questions.value.filter(question => {
    if (viewMode.value === 'unanswered' && question.replies?.length) return false
    if (!query) return true
    return [question.title, question.content, question.courseTitle, question.userName]
      .some(value => String(value || '').toLocaleLowerCase().includes(query))
  })
  result = [...result]
  if (viewMode.value === 'active') {
    result.sort((a, b) => (b.replies?.length || 0) - (a.replies?.length || 0))
  } else {
    result.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
  }
  return result
})

function formatDate(value) {
  const date = withDisplayYear(value)
  return date ? date.toLocaleString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' }) : ''
}

async function loadCourses() {
  // This page reports the startup error below; suppress the request layer's
  // global toast so a failed course request does not produce two identical notices.
  const page = await getCoursePage(
    { current: 1, size: 100, status: 1 },
    { showDefaultMsg: false }
  )
  courseOptions.value = page?.records || []
}

async function loadQuestions() {
  loading.value = true
  try {
    questions.value = (await getQuestions(courseFilter.value)) || []
  } catch (error) {
    message.error(error.message || '讨论列表暂时无法加载')
  } finally {
    loading.value = false
  }
}

async function postQuestion() {
  posting.value = true
  try {
    await createQuestion(form)
    message.success('讨论已发布')
    form.title = ''
    form.content = ''
    await loadQuestions()
  } catch (error) {
    message.error(error.message || '发布失败')
  } finally {
    posting.value = false
  }
}

async function sendReply(questionId) {
  const content = (replyDrafts[questionId] || '').trim()
  if (!content) return
  replyingId.value = questionId
  try {
    await replyToQuestion(questionId, { content })
    replyDrafts[questionId] = ''
    await loadQuestions()
  } catch (error) {
    message.error(error.message || '回复失败')
  } finally {
    replyingId.value = null
  }
}

onMounted(async () => {
  try {
    await loadCourses()
    if (courseOptions.value.length) form.courseId = courseOptions.value[0].id
    await loadQuestions()
  } catch (error) {
    message.error(error.message || '课程列表暂时无法加载')
  }
})
</script>

<style scoped>
.community-page { color:#34362d; }
.discussion-item h3,.question-content,.reply-item p { overflow-wrap:anywhere; }
.forum-shell { width:min(1280px,calc(100% - 96px)); margin:0 auto; padding:46px 0 80px; display:grid; grid-template-columns:minmax(0,1fr) 275px; gap:48px; }
.forum-main { min-width:0; }.forum-channel-bar { display:flex; align-items:center; justify-content:space-between; gap:20px; border-bottom:1px solid #ccbda3; padding-bottom:20px; }.forum-channel-bar>span { color:#9a8161; font:10px Arial,sans-serif; letter-spacing:.12em; }.course-filter { width:250px; }
.compose-section { padding:26px 24px 6px; margin-top:24px; border:1px solid #d8cbb6; background:#fffdf782; }.compose-section :deep(.ant-form-item-label) { font-size:12px; }.sign-in-line { display:flex; align-items:center; justify-content:space-between; padding:20px 0; border-bottom:1px solid #ded5c4; color:#8a7a63; font-size:12px; }
.discussion-toolbar { display:flex; align-items:center; justify-content:space-between; padding:28px 0 15px; }.discussion-toolbar h2 { font:400 25px 'Songti SC',serif; letter-spacing:.1em; margin:0; }.discussion-count { margin-left:15px; color:#a38d6f; font:11px Arial,sans-serif; }.discussion-filters { display:flex; align-items:center; justify-content:space-between; gap:16px; padding-bottom:24px; border-bottom:2px solid #a88c66; }.discussion-search { max-width:330px; }
.discussion-item { position:relative; padding:29px 0 26px 22px; border-bottom:1px solid #d8cbb6; }.discussion-item:before { content:''; position:absolute; top:35px; left:0; width:5px; height:5px; border:1px solid #ab8d61; transform:rotate(45deg); }.discussion-meta,.reply-author { display:flex; align-items:center; gap:9px; flex-wrap:wrap; color:#a09480; font-size:10px; }.discussion-meta time,.reply-author time { margin-left:auto; }.discussion-item h3 { margin:17px 0 13px; font:500 21px/1.6 'Songti SC',serif; letter-spacing:.04em; }.question-content { color:#736f63; font-size:13px; line-height:2; white-space:pre-wrap; margin:0; }.reply-list { margin-top:23px; padding:8px 19px; background:#eae6da8c; border-left:2px solid #a89676; }.reply-item { padding:12px 0; }.reply-item+.reply-item { border-top:1px solid #d9cfbd; }.reply-author strong { color:#62705b; }.reply-item p { margin:8px 0 0; color:#777366; font-size:12px; line-height:1.9; white-space:pre-wrap; }.discussion-footer { display:flex; align-items:center; gap:15px; margin-top:18px; color:#a08e73; font-size:10px; }.unanswered-label { color:#ad523b; }.reply-compose { display:flex; gap:9px; margin-top:16px; }
.forum-aside-intro { padding:33px 27px; background:#314237; color:#e8decb; border-top:3px solid #b9a17a; }.forum-aside-intro>svg { display:block; width:28px; height:28px; color:#c1a57a; margin-bottom:25px; }.forum-aside-intro>span { color:#baa98a; font-size:10px; letter-spacing:.15em; }.forum-aside-intro h2 { font:400 28px/1.7 'Songti SC',serif; color:#f0e7d4; letter-spacing:.1em; margin:14px 0; }.forum-aside-intro p { color:#c8c6b59c; font-size:11px; line-height:2; }.forum-counts { display:grid; grid-template-columns:1fr 1fr; margin-top:30px; padding-top:20px; border-top:1px solid #c4b59642; gap:15px; }.forum-counts strong { font:28px Georgia,serif; color:#d0b58a; display:block; }.forum-counts span { display:block; font-size:10px; margin-top:7px; color:#c3b79d; }
.forum-guide { padding:30px 24px; border:1px solid #d7cbb6; border-top:0; background:#fffdf642; }.forum-guide small { color:#b19a76; font:9px Arial,sans-serif; letter-spacing:.14em; }.forum-guide h3 { font:400 20px 'Songti SC',serif; letter-spacing:.12em; margin:13px 0 24px; }.forum-guide p { font-size:11px; line-height:2; color:#9b8b72; margin:18px 0; }.forum-guide b { color:#ad6549; font:12px Georgia,serif; margin-right:4px; }.forum-guide a { display:flex; justify-content:space-between; margin-top:25px; padding-top:16px; border-top:1px solid #d7cbb6; color:#8d4a37; font-size:11px; }
@media(max-width:1000px) { .forum-shell { gap:26px; grid-template-columns:minmax(0,1fr) 220px; }.forum-aside-intro,.forum-guide { padding-inline:20px; }.discussion-filters { align-items:stretch; flex-direction:column; }.discussion-search { max-width:100%; } }
@media(max-width:760px) { .forum-shell { width:calc(100% - 44px); grid-template-columns:1fr; padding:28px 0 50px; }.forum-aside { display:grid; grid-template-columns:1fr 1fr; gap:0; }.forum-aside-intro { padding:24px 18px; }.forum-aside-intro h2 { font-size:22px; }.forum-guide { border-top:1px solid #d7cbb6; padding:24px 16px; }.forum-channel-bar { flex-wrap:wrap; gap:14px; }.course-filter { width:100%; }.discussion-item { padding:24px 0 24px 15px; }.discussion-meta time { margin-left:0; }.discussion-item h3 { font-size:19px; }.question-content { font-size:12px; }.reply-list { padding-inline:12px; }.discussion-toolbar h2 { font-size:23px; }.compose-section { padding:22px 16px 4px; } }
</style>
