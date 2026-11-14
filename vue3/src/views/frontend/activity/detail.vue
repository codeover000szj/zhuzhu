<template>
  <div class="activity-detail">
    <a-spin :spinning="loading">
      <div
        v-if="activity"
        class="detail-container"
      >
        <nav
          class="detail-breadcrumb"
          aria-label="当前位置"
        >
          <router-link to="/home">
            首页
          </router-link><span>/</span><router-link to="/activity">
            活动中心
          </router-link><span>/</span><span>活动详情</span>
        </nav>
        <!-- 活动信息 -->
        <div class="activity-info">
          <a-row :gutter="32">
            <a-col
              :xs="24"
              :lg="12"
            >
              <!-- 封面图 -->
              <div class="activity-cover">
                <img
                  :src="getActivityCover()"
                  :alt="showCoverCredit ? verifiedSource.imageAlt : activity.title"
                >
              </div>
              <p v-if="showCoverCredit" class="cover-credit">{{ verifiedSource.imageCredit }}</p>
            </a-col>

            <a-col
              :xs="24"
              :lg="12"
            >
              <!-- 活动标题和基本信息 -->
              <div class="activity-header">
                <span class="detail-kicker">HERITAGE IN THE PRESENT / 文化现场</span>
                <h1>{{ activity.title }}</h1>
                <div class="activity-tags">
                  <a-tag>{{ activity.type }}</a-tag>
                  <a-tag :color="getStatusColor(activity.status)">
                    {{ externalStatus }}
                  </a-tag>
                </div>

                <!-- 快速信息 -->
                <div class="quick-info">
                  <div class="info-row">
                    <i class="fas fa-calendar-alt" />
                    <div class="info-content">
                      <span class="label">活动时间</span>
                      <span class="value">{{ formatDateTime(activity.startTime) }}</span>
                      <span class="value">至 {{ formatDateTime(activity.endTime) }}</span>
                    </div>
                  </div>
                  <div class="info-row">
                    <i class="fas fa-map-marker-alt" />
                    <div class="info-content">
                      <span class="label">活动地点</span>
                      <span class="value">{{ activity.location || '待定' }}</span>
                    </div>
                  </div>
                  <div v-if="!verifiedSource" class="info-row">
                    <i class="fas fa-users" />
                    <div class="info-content">
                      <span class="label">报名人数</span>
                      <span class="value">{{ activity.signupCount || 0 }} 人</span>
                    </div>
                  </div>
                </div>

                <!-- 报名按钮 -->
                <div class="action-buttons">
                  <template v-if="verifiedSource">
                    <a :href="verifiedSource.sourceUrl" target="_blank" rel="noopener noreferrer" class="official-source-link">阅读官方活动资讯 <span aria-hidden="true">↗</span></a>
                    <p class="source-action-note">{{ externalStatus === '活动回顾' ? '本场活动已结束，可通过来源报道回顾现场。' : '参会资格、开放安排与日程以主办方公告为准。' }}</p>
                  </template>
                  <template v-else-if="activity.status === 1">
                    <a-button
                      type="primary"
                      size="large"
                      block
                      @click="handleSignup"
                    >
                      <i class="fas fa-edit" />
                      立即报名
                    </a-button>
                  </template>
                  <template v-else-if="activity.status === 2">
                    <a-button
                      size="large"
                      block
                      disabled
                    >
                      <i class="fas fa-clock" />
                      活动进行中
                    </a-button>
                  </template>
                  <template v-else-if="activity.status === 3">
                    <a-button
                      size="large"
                      block
                      disabled
                    >
                      <i class="fas fa-times-circle" />
                      活动已结束
                    </a-button>
                  </template>
                  <template v-else>
                    <a-button
                      size="large"
                      block
                      disabled
                    >
                      <i class="fas fa-hourglass-half" />
                      筹备中
                    </a-button>
                  </template>
                </div>
              </div>
            </a-col>
          </a-row>

          <!-- 活动详情区域 -->
          <a-row
            :gutter="32"
            style="margin-top: 32px;"
          >
            <a-col
              :xs="24"
              :lg="16"
            >
              <!-- 活动描述 -->
              <div class="info-section">
                <h2>
                  <i class="fas fa-file-alt" /> 活动详情
                </h2>
                <div class="activity-description">
                  {{ activity.description || '暂无详细描述' }}
                </div>
                <aside v-if="verifiedSource" class="verified-source-card">
                  <span class="detail-kicker">VERIFIED PUBLIC SOURCE</span>
                  <h3>让每一次相遇，有源可循</h3>
                  <p>{{ verifiedSource.sourceName }}</p>
                  <a :href="verifiedSource.sourceUrl" target="_blank" rel="noopener noreferrer">阅读完整公开报道 <span aria-hidden="true">↗</span></a>
                </aside>
              </div>
            </a-col>

            <a-col
              :xs="24"
              :lg="8"
            >
              <!-- 报名须知 -->
              <div class="signup-tips-card">
                <span class="detail-kicker">BEFORE YOU GO</span><h3>
                  <i class="fas fa-info-circle" />
                  {{ verifiedSource ? '活动阅读指引' : '报名须知' }}
                </h3>
                <ul v-if="verifiedSource">
                  <li>信息来自公开报道，本站收录为活动资讯</li>
                  <li>日期按报道记录，未公布具体入场时刻</li>
                  <li>不提供官方活动的代报名服务</li>
                  <li>场次、票务和参与方式请查阅主办方公告</li>
                </ul>
                <ul v-else>
                  <li>请确保个人信息准确无误</li>
                  <li>报名后请等待审核通知</li>
                  <li>活动当天请准时签到</li>
                  <li>如有疑问请联系工作人员</li>
                </ul>
              </div>
            </a-col>
          </a-row>
        </div>
      </div>
    </a-spin>

    <!-- 报名弹窗 -->
    <a-modal
      v-model:open="isSignupModalVisible"
      title="活动报名"
      @ok="handleSignupOk"
      @cancel="isSignupModalVisible = false"
    >
      <div class="signup-form">
        <h3>{{ activity?.title }}</h3>
        <p><strong>活动时间：</strong>{{ formatDateTime(activity?.startTime) }} 至 {{ formatDateTime(activity?.endTime) }}</p>
        <p><strong>活动地点：</strong>{{ activity?.location }}</p>
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { getActivityDetail, signupActivity } from '@/api/ActivityApi'
import { useUserStore } from '@/store/user'
import { withDisplayYear } from '@/utils/dateUtils'
import verifiedActivities from '@/data/verifiedActivities.json'
import activityArchives from '@/data/activityArchives.json'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activity = ref(null)
const activitySources = [...verifiedActivities, ...activityArchives]
const verifiedSource = computed(() => activitySources.find(item => item.id === activity.value?.id))
const showCoverCredit = computed(() => Boolean(verifiedSource.value?.imageCredit && getActivityCover() === verifiedSource.value.cover))
const externalStatus = computed(() => {
  if (!verifiedSource.value) return activity.value?.statusName
  const startsAt = activity.value?.startTime ? dayjs(activity.value.startTime) : null
  const endsAt = activity.value?.endTime ? dayjs(activity.value.endTime) : null
  if (startsAt?.isValid() && dayjs().isBefore(startsAt)) return '即将举行 · 官方资讯'
  if (endsAt?.isValid() && dayjs().isAfter(endsAt)) return '活动回顾'
  if (!startsAt?.isValid() || !endsAt?.isValid()) return activity.value?.statusName || '官方活动资讯'
  return '进行中 · 官方资讯'
})
const loading = ref(false)
const isSignupModalVisible = ref(false)

// 加载活动详情
const loadDetail = () => {
  loading.value = true
  const verifiedActivity = verifiedActivities.find(item => item.id === route.params.id)
  if (verifiedActivity) {
    const startsAt = dayjs(verifiedActivity.startTime)
    const endsAt = dayjs(verifiedActivity.endTime)
    const status = dayjs().isBefore(startsAt) ? 1 : dayjs().isAfter(endsAt) ? 3 : 2
    activity.value = {
      id: verifiedActivity.id,
      title: verifiedActivity.title,
      type: verifiedActivity.type,
      startTime: verifiedActivity.startTime,
      endTime: verifiedActivity.endTime,
      location: verifiedActivity.location,
      description: verifiedActivity.description,
      status,
      statusName: status === 1 ? '即将举行' : status === 2 ? '进行中' : '活动回顾',
      coverFilePath: verifiedActivity.cover
    }
    loading.value = false
    return
  }
  getActivityDetail(
    { activityId: route.params.id },
    {
      onSuccess: (data) => {
        activity.value = data
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

// 报名
const handleSignup = () => {
  if (!userStore.isLoggedIn) {
    message.warning('请先登录')
    router.push({ path: '/auth/login', query: { redirect: route.fullPath } })
    return
  }
  isSignupModalVisible.value = true
}

// 确认报名
const handleSignupOk = () => {
  if (!userStore.userId) {
    message.error('用户信息异常')
    return
  }

  // 活动ID是字符串格式（UUID），直接使用
  const activityId = activity.value.id
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
        loadDetail() // 刷新数据
      },
      successMsg: false
    }
  )
}

// 工具函数
const getStatusColor = (status) => {
  const colors = {
    0: 'default',
    1: 'blue',
    2: 'green',
    3: 'gray'
  }
  return colors[status] || 'default'
}

const getActivityCover = () => {
  if (activity.value?.coverFilePath) {
    const path = activity.value.coverFilePath
    if (path.startsWith('http')) return path
    // 静态资源直接访问，不需要API前缀
    return path.startsWith('/') ? path : '/' + path
  }
  if (verifiedSource.value?.cover) return verifiedSource.value.cover
  return '/images/activity-placeholder.svg'
}

const formatDateTime = (dateStr) => {
  const date = withDisplayYear(dateStr)
  return date ? dayjs(date).format(verifiedSource.value ? 'YYYY年MM月DD日' : 'YYYY-MM-DD HH:mm') : '-'
}

onMounted(() => {
  loadDetail()
})
watch(() => route.params.id, (id) => { if (id) loadDetail() })
</script>

<style scoped>
.cover-credit { margin:12px 0 0;color:#96866e;font-size:10px;line-height:1.8; }
.official-source-link { display:flex;align-items:center;justify-content:center;gap:30px;min-height:48px;background:#96392b;border:1px solid #96392b;color:#fff3dc;font-size:13px;letter-spacing:.1em;transition:background .3s,box-shadow .3s; }.official-source-link:hover { color:#fff7e9;background:#7d2d23;box-shadow:0 6px 20px #73312424; }.official-source-link span { transition:transform .3s; }.official-source-link:hover span { transform:translate(3px,-3px); }.source-action-note { color:#9c8e78;font-size:11px;line-height:1.8;margin:13px 0 0; }
.verified-source-card { background:#ebe6d8;border:1px solid #d4c4a9;margin-top:30px;padding:25px 28px; }.verified-source-card .detail-kicker { margin-bottom:10px; }.verified-source-card h3 { font:400 22px/1.6 'Songti SC','SimSun',serif;color:#354c3e;letter-spacing:.08em; }.verified-source-card p { color:#93816a;font-size:12px; }.verified-source-card a { display:flex;align-items:center;justify-content:space-between;gap:16px;color:#954133;border-top:1px solid #cbbda4;margin-top:17px;padding-top:17px;font-size:12px; }.verified-source-card a:hover { color:#702b20; }
@media(max-width:760px) { .verified-source-card { padding:23px; }.verified-source-card h3 { font-size:20px; } }
@media(prefers-reduced-motion:reduce) { .official-source-link,.official-source-link span { transition:none; } }


.detail-breadcrumb { display: flex; gap: 13px; align-items: center; padding: 29px 0; font-size: 11px; color: #a39783; }.detail-breadcrumb a { color: #8b7c63; }.detail-breadcrumb a:hover { color: #9f3026; }.detail-breadcrumb span:last-child { color: #3c4e43; }
.detail-kicker { display: block; color: #b09369; font: 9px/1.8 Arial,sans-serif; letter-spacing: .17em; margin-bottom: 18px; }
@media(max-width:760px) { .detail-breadcrumb { padding: 22px 0; font-size: 10px; gap: 10px; } }

.activity-detail { min-height: 100vh; padding: 0 48px 70px; background: #f7f4ec; color: #3b3b31; }.detail-container { max-width: 1280px; margin: auto; }.activity-info { padding: 0; }.activity-info>.ant-row:first-child { padding-bottom: 50px; border-bottom: 1px solid #cdbfa7; }
.activity-cover { width: 100%; height: 100%; min-height: 490px; overflow: hidden; position: relative; padding: 10px; border: 1px solid #cbbca4; }.activity-cover:after { content:''; position:absolute; inset: 6px; border:1px solid #e9e1d3; pointer-events:none; }.activity-cover img { width: 100%; height: 100%; min-height: 468px; object-fit: cover; display: block; }
.activity-header { padding: 12px 15px 0 16px; }.activity-header h1 { font: 400 35px/1.6 'Songti SC','SimSun',serif; letter-spacing: .07em; color: #313d34; margin: 0 0 20px; }.activity-tags { display: flex; margin-bottom: 27px; }.activity-tags :deep(.ant-tag) { border-radius: 0; background: transparent; color: #996946; border-color: #bca683; padding: 3px 10px; font-size: 11px; }.activity-tags :deep(.ant-tag:last-child) { color: #3b6550; border-color: #a8b6a8; }
.quick-info { padding: 22px 0; border-top: 1px solid #ccbea5; border-bottom: 1px solid #ccbea5; margin-bottom: 27px; }.info-row { display: flex; align-items: flex-start; gap: 17px; margin-bottom: 22px; }.info-row:last-child { margin: 0; }.info-row>i { color: #a68d65; width: 19px; flex-shrink: 0; margin-top: 4px; font-size: 14px; }.info-content { display: flex; flex-direction: column; gap: 3px; }.info-content .label { color: #9e9078; font-size: 10px; letter-spacing: .13em; margin-bottom: 4px; }.info-content .value { font-size: 14px; color: #5f5d4e; line-height: 1.8; }.action-buttons :deep(.ant-btn) { height: 46px; border-radius: 0; letter-spacing: .15em; font-size: 14px; }.action-buttons :deep(.ant-btn-primary) { background: #a02e25; border-color: #a02e25; }.action-buttons :deep(.ant-btn-primary:hover) { background: #7c2019; border-color: #7c2019; }
.info-section { padding: 18px 25px 18px 0; }.info-section h2 { display: flex; align-items: center; gap: 13px; font: 400 25px/1.5 'Songti SC','SimSun',serif; color: #3b4438; letter-spacing: .15em; margin: 0 0 28px; border-bottom: 1px solid #d3c6ae; padding-bottom: 18px; }.info-section h2 i { color: #a3825d; font-size: 17px; }.activity-description { white-space: pre-wrap; color: #77705f; font-size: 14px; line-height: 2.2; text-align: justify; }
.signup-tips-card { padding: 28px; background: #ebe6d8; border-top: 3px solid #344e41; margin-top: 18px; }.signup-tips-card h3 { color: #344a3c; font: 400 21px 'Songti SC',serif; letter-spacing: .1em; margin: 0 0 20px; }.signup-tips-card h3 i { font-size: 15px; margin-right: 8px; color: #aa8b5f; }.signup-tips-card ul { padding: 0 0 0 17px; margin: 0; }.signup-tips-card li { font-size: 12px; color: #8b7f69; line-height: 2.3; padding-bottom: 5px; }.signup-form { color: #625747; }.signup-form h3 { font-family: 'Songti SC',serif; font-size: 22px; }.signup-form p { line-height: 1.9; font-size: 13px; }
@media(max-width:1100px) { .activity-cover { min-height: 450px; }.activity-cover img { min-height: 428px; }.activity-header { padding-inline: 5px; }.activity-header h1 { font-size: 30px; }.info-content .value { font-size: 12px; } }
@media(max-width:991px) { .activity-cover { height: 410px; min-height: unset; margin-bottom: 27px; }.activity-cover img { min-height: unset; height: 100%; }.activity-header { padding: 0; }.activity-header h1 { font-size: 31px; }.activity-info>.ant-row:first-child { padding-bottom: 35px; }.signup-tips-card { margin-top: 24px; }.info-section { padding-right: 0; } }
@media(max-width:760px) { .activity-detail { padding: 0 22px 45px; }.activity-cover { height: 300px; padding: 7px; }.activity-header h1 { font-size: 25px; line-height: 1.7; }.detail-kicker { font-size: 8px; }.quick-info { padding: 18px 0; }.info-content .value { font-size: 12px; }.info-section h2 { font-size: 23px; }.activity-description { font-size: 12px; line-height: 2.15; }.signup-tips-card { padding: 25px; } }

</style>
