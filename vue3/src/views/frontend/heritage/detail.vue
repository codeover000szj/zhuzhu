<template>
  <div class="heritage-detail-page">
    <!-- 加载状态 -->
    <div
      v-if="loading"
      class="loading-container"
    >
      <a-skeleton
        :rows="10"
        active
      />
    </div>

    <!-- 作品详情 -->
    <div
      v-else-if="currentItem"
      class="detail-container"
    >
      <!-- 页面头部 -->
      <div class="detail-header">
        <div class="header-content">
          <div class="header-left">
            <div class="header-breadcrumb">
              <a-breadcrumb>
                <a-breadcrumb-item href="/">
                  首页
                </a-breadcrumb-item>
                <a-breadcrumb-item href="/heritage">
                  非遗作品
                </a-breadcrumb-item>
                <a-breadcrumb-item>{{ currentItem.title }}</a-breadcrumb-item>
              </a-breadcrumb>
            </div>
            
            <div class="header-title-section">
              <p class="detail-eyebrow">
                COLLECTION · CULTURAL MEMORY
              </p>
              <h1 class="detail-title">
                {{ currentItem.title }}
              </h1>
              <div class="header-meta">
                <a-tag class="category-tag">
                  {{ currentItem.category }}
                </a-tag>
                <span
                  v-if="currentItem.region"
                  class="region-tag"
                >
                  <i class="fas fa-map-marker-alt" />
                  {{ currentItem.region }}
                </span>
                <span class="publish-time">
                  <i class="fas fa-clock" />
                  {{ formatDate(currentItem.publishTime || currentItem.createTime) }}
                </span>
              </div>
              <button
                class="back-link"
                @click="handleBackToList"
              >
                <span aria-hidden="true">←</span> 返回作品典藏
              </button>
            </div>
          </div>
          
          <div class="header-cover">
            <img 
              v-if="currentItem.coverImage" 
              :src="currentItem.coverImage" 
              :alt="currentItem.title"
              class="cover-image"
            >
            <div
              v-else
              class="no-cover"
            >
              <i class="fas fa-image" />
              <p>暂无封面</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 主体内容 -->
      <div class="detail-body">
        <!-- 左侧：媒体展示 -->
        <div class="media-section">
          <!-- 主要媒体展示 -->
          <div class="main-media">
            <div
              v-if="mainMedia"
              class="media-display"
            >
              <!-- 图片展示 -->
              <div v-if="mainMedia.type === 'IMG'" class="image-viewer">
                <Transition name="artwork-fade" mode="out-in">
                  <button
                    :key="mainMedia.filePath"
                    type="button"
                    class="image-preview-trigger"
                    :aria-label="`${currentItem.title}，放大查看原图`"
                    @click="openImagePreview"
                  >
                    <img :src="mainMedia.filePath" :alt="currentItem.title" class="main-image">
                    <span class="image-preview-hint"><i class="fas fa-expand" aria-hidden="true" /> 放大细览</span>
                  </button>
                </Transition>
              </div>
              
              <!-- 视频展示 -->
              <video 
                v-else-if="mainMedia.type === 'VIDEO'" 
                :src="mainMedia.filePath" 
                controls 
                class="main-video"
              >
                您的浏览器不支持视频播放
              </video>
              
              <!-- 音频展示 -->
              <div
                v-else-if="mainMedia.type === 'AUDIO'"
                class="audio-player"
              >
                <i class="fas fa-music" />
                <audio
                  :src="mainMedia.filePath"
                  controls
                  class="main-audio"
                >
                  您的浏览器不支持音频播放
                </audio>
              </div>
              
              <!-- 无媒体时显示默认图 -->
              <div
                v-else
                class="no-media"
              >
                <i class="fas fa-image" />
                <p>暂无媒体文件</p>
              </div>
            </div>
            <div
              v-else
              class="no-media"
            >
              <i class="fas fa-image" />
              <p>暂无媒体文件</p>
            </div>
          </div>

          <!-- 媒体缩略图列表 -->
          <div
            v-if="mediaList.length > 1"
            class="media-thumbnails"
          >
            <button
              v-for="(media, index) in mediaList" 
              :key="media.id || media.filePath"
              type="button"
              class="thumbnail-item"
              :class="{ active: currentMediaIndex === index }"
              :aria-pressed="currentMediaIndex === index"
              :aria-label="`切换至第 ${index + 1} 个媒体：${getMediaTypeLabel(media.type)} · ${media.originalName || currentItem.title}`"
              @click="handleMediaChange(index)"
            >
              <img 
                v-if="media.type === 'IMG'" 
                :src="media.filePath" 
                alt=""
              >
              <div
                v-else
                class="thumbnail-icon"
              >
                <i :class="getMediaIcon(media.type)" />
              </div>
            </button>
          </div>
          <p v-if="mainMedia" class="media-caption"><span>作品影像 · {{ getMediaTypeLabel(mainMedia.type) }}</span><span>{{ currentMediaIndex + 1 }} / {{ mediaList.length || 1 }}</span></p>
        </div>

        <!-- 右侧：作品信息 -->
        <div class="info-section">
          <!-- 摘要 -->
          <div
            v-if="currentItem.summary"
            class="summary-box"
          >
            <h3>作品摘要</h3>
            <p class="summary-text">
              {{ currentItem.summary }}
            </p>
          </div>

          <!-- 详细描述 -->
          <div class="description-box">
            <h3>详细介绍</h3>
            <div
              v-if="currentItem.description"
              class="description-content"
              v-html="formatDescription(currentItem.description)"
            />
            <div
              v-else
              class="no-content"
            >
              暂无详细介绍
            </div>
          </div>

          <div class="archive-box">
            <h3>作品档案</h3>
            <dl class="archive-grid">
              <template v-if="currentItem.archiveCode">
                <dt>档案编号</dt><dd>{{ currentItem.archiveCode }}</dd>
              </template>
              <template v-if="currentItem.processSummary">
                <dt>工艺流程</dt><dd>{{ currentItem.processSummary }}</dd>
              </template>
              <template v-if="currentItem.materialList">
                <dt>主要材料</dt><dd>{{ currentItem.materialList }}</dd>
              </template>
              <template v-if="currentItem.preservationNotes">
                <dt>保存记录</dt><dd>{{ currentItem.preservationNotes }}</dd>
              </template>
              <template v-if="currentItem.rightsNotice">
                <dt>授权说明</dt><dd>{{ currentItem.rightsNotice }}</dd>
              </template>
              <template v-if="currentItem.coverSourceUrl">
                <dt>配图来源</dt>
                <dd>
                  <a
                    :href="currentItem.coverSourceUrl"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    {{ currentItem.coverAttribution || '查看原始图片页面' }}
                  </a>
                </dd>
              </template>
              <dd
                v-if="!currentItem.archiveCode && !currentItem.processSummary && !currentItem.materialList && !currentItem.preservationNotes && !currentItem.rightsNotice && !currentItem.coverSourceUrl"
                class="archive-empty"
              >
                档案信息待补充
              </dd>
            </dl>
          </div>

          <!-- 创建人信息 -->
          <div
            v-if="currentItem.creatorName"
            class="creator-box"
          >
            <h3>创建人</h3>
            <div class="creator-info">
              <i class="fas fa-user-circle" />
              <span>{{ currentItem.creatorName }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 关联传承人 -->
      <div
        v-if="currentItem.inheritorList && currentItem.inheritorList.length > 0"
        class="inheritor-section"
      >
        <h2>相关传承人</h2>
        <div class="inheritor-grid">
          <div 
            v-for="inheritor in currentItem.inheritorList" 
            :key="inheritor.id"
            class="inheritor-card"
          >
            <div class="inheritor-avatar">
              <img
                v-if="inheritor.avatarPath"
                :src="inheritor.avatarPath"
                :alt="inheritor.name"
              >
              <i
                v-else
                class="fas fa-user"
              />
            </div>
            <div class="inheritor-info">
              <h4>{{ inheritor.name }}</h4>
              <p class="inheritor-title">
                {{ inheritor.title || '传承人' }}
              </p>
              <p class="inheritor-region">
                <i class="fas fa-map-marker-alt" />
                {{ inheritor.region || '未知地区' }}
              </p>
            </div>
            <a-button
              type="primary"
              size="small"
              @click="router.push(`/inheritor/${inheritor.id}`)"
            >
              了解更多
            </a-button>
          </div>
        </div>
      </div>

      <!-- 相关推荐 -->
      <div
        v-if="relatedItems.length > 0"
        class="related-section"
      >
        <h2>相关作品推荐</h2>
        <div class="related-grid">
          <HeritageItemCard
            v-for="item in relatedItems"
            :key="item.id"
            :item="item"
            @click="handleRelatedItemClick"
          />
        </div>
      </div>
    </div>

    <!-- 未找到 -->
    <div
      v-else
      class="not-found"
    >
      <i class="fas fa-exclamation-triangle" />
      <p>未找到该作品</p>
      <a-button
        type="primary"
        @click="handleBackToList"
      >
        返回列表
      </a-button>
    </div>

    <a-modal
      v-model:open="imagePreviewOpen"
      :title="`${currentItem?.title || '作品'} · 图像细览`"
      :footer="null"
      :keyboard="true"
      :focus-trigger-after-close="true"
      :destroy-on-close="true"
      width="min(1200px, calc(100vw - 32px))"
      :body-style="{ padding: '12px', background: '#f6f2e9' }"
    >
      <div class="artwork-preview-frame">
        <img :src="previewImage" :alt="currentItem?.title || '作品原图'">
        <p>细览作品图像 <span>按 Esc 或点击关闭按钮返回</span></p>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { 
  getHeritageItemDetail, 
  getHeritageItemPage
} from '@/api/HeritageApi'
import HeritageItemCard from '@/components/common/HeritageItemCard.vue'
import { formatLocalDate } from '@/utils/dateUtils'

// ========== 路由 ==========
const route = useRoute()
const router = useRouter()

// ========== 响应式数据 ==========
const loading = ref(false)
const currentItem = ref(null)
const mediaList = ref([])
const currentMediaIndex = ref(0)
const relatedItems = ref([])
const imagePreviewOpen = ref(false)
const previewImage = ref('')

// ========== 计算属性 ==========
const mainMedia = computed(() => {
  const selectedMedia = mediaList.value[currentMediaIndex.value]
  if (selectedMedia) return selectedMedia

  const coverImage = currentItem.value?.coverImage
  return coverImage
    ? { id: 'cover', type: 'IMG', filePath: coverImage, originalName: `${currentItem.value.title}封面` }
    : null
})

// ========== 方法 ==========

/**
 * 格式化日期
 */
function formatDate(dateStr) {
  if (!dateStr) return ''
  try {
    return formatLocalDate(dateStr)
  } catch (error) {
    return ''
  }
}

/**
 * 格式化描述
 */
function formatDescription(description) {
  if (!description) return ''
  // 将换行符转换为HTML换行
  return description.replace(/\n/g, '<br>')
}

/**
 * 获取媒体图标
 */
function getMediaIcon(type) {
  const iconMap = {
    VIDEO: 'fas fa-play-circle',
    AUDIO: 'fas fa-music',
    PDF: 'fas fa-file-pdf',
    FILE: 'fas fa-file'
  }
  return iconMap[type] || 'fas fa-file'
}

function getMediaTypeLabel(type) {
  return { IMG: '图片', VIDEO: '视频', AUDIO: '音频', PDF: '文档', FILE: '文件' }[type] || '资料'
}

function openImagePreview() {
  if (mainMedia.value?.type !== 'IMG') return
  previewImage.value = mainMedia.value.filePath
  imagePreviewOpen.value = true
}

/**
 * 获取作品详情
 */
function fetchItemDetail() {
  const itemId = route.params.id
  if (!itemId) {
    message.error('作品ID不能为空')
    handleBackToList()
    return
  }

  loading.value = true
  
  getHeritageItemDetail({ itemId }, {
    onSuccess: (res) => {
      currentItem.value = res
      loading.value = false
      
      // 直接从作品详情中获取媒体文件列表
      if (res.mediaList && res.mediaList.length > 0) {
        mediaList.value = res.mediaList
        currentMediaIndex.value = 0
        console.log(`成功加载 ${res.mediaList.length} 个媒体文件`)
      } else {
        mediaList.value = []
        currentMediaIndex.value = 0
      }
      
      // 获取相关推荐
      fetchRelatedItems(res.category)
    },
    onError: () => {
      message.error('获取作品详情失败')
      loading.value = false
    }
  })
}

// fetchMediaList 函数已移除，直接从作品详情中获取媒体文件

/**
 * 获取相关推荐
 */
function fetchRelatedItems(category) {
  if (!category) return
  
  getHeritageItemPage({ 
    category, 
    status: 2, 
    currentPage: 1, 
    size: 4 
  }, {
    onSuccess: (res) => {
      // 排除当前作品
      relatedItems.value = (res.records || []).filter(
        item => item.id !== currentItem.value.id
      )
    },
    onError: (error) => {
      console.error('获取相关作品失败:', error)
    }
  })
}

/**
 * 切换媒体
 */
function handleMediaChange(index) {
  currentMediaIndex.value = index
}

/**
 * 分享处理
 */
/**
 * 返回列表
 */
function handleBackToList() {
  router.push('/heritage')
}

/**
 * 相关作品点击
 */
function handleRelatedItemClick(item) {
  router.push(`/heritage/${item.id}`)
}

watch(() => route.params.id, () => {
  imagePreviewOpen.value = false
  if (route.name === 'HeritageDetail' || route.path.startsWith('/heritage/')) {
    relatedItems.value = []
    fetchItemDetail()
  }
})

// ========== 生命周期 ==========
onMounted(() => {
  fetchItemDetail()
})
</script>

<style scoped>
.heritage-detail-page { min-height: 70vh; color: #3d453b; background: #f6f2e9; }
.detail-container { max-width: 1320px; width: calc(100% - 96px); margin: 0 auto; padding: 0 0 80px; }
.detail-header { padding: 35px 0 42px; border-bottom: 1px solid #d9d0bf; position: relative; }
.detail-header::after { content: ''; position: absolute; bottom: -1px; left: 0; width: 100px; height: 3px; background: #a44034; }
.header-content { display: grid; grid-template-columns: 1fr 260px; gap: 60px; align-items: center; }
.header-breadcrumb { margin-bottom: 42px; }
.header-breadcrumb :deep(.ant-breadcrumb) { font-size: 12px; color: #9b8e79; }
.header-breadcrumb :deep(a) { color: #8e806b; }
.detail-eyebrow { margin-bottom: 17px; color: #a44034; font-size: 10px; letter-spacing: 3px; }
.detail-title { margin: 0 0 25px; font: 500 clamp(30px, 4.4vw, 58px)/1.4 'Songti SC', 'STSong', 'SimSun', serif; letter-spacing: 4px; color: #253d32; }
.header-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 22px; font-size: 12px; color: #9a8c76; }
.category-tag { padding: 3px 12px; margin: 0; color: #a44034; background: transparent; border: 1px solid #b88b76; border-radius: 0; }
.region-tag i, .publish-time i { margin-right: 5px; opacity: .65; }
.back-link { margin-top: 28px; border: 0; padding: 0; background: none; color: #71664f; font-size: 12px; letter-spacing: 1px; cursor: pointer; transition: color .2s; }
.back-link span { margin-right: 8px; }
.back-link:hover { color: #a44034; }
.header-cover { height: 235px; margin-top: 40px; padding: 8px; border: 1px solid #d9cfbc; position: relative; }
.header-cover::before { content: '数字典藏'; position: absolute; right: -12px; top: -12px; padding: 10px 6px; writing-mode: vertical-rl; background: #a44034; color: #fff8e7; letter-spacing: 4px; font: 14px 'Songti SC', serif; z-index: 1; }
.cover-image { height: 100%; width: 100%; object-fit: cover; }
.no-cover { height: 100%; display: grid; align-content: center; justify-content: center; gap: 10px; text-align: center; color: #a6977e; background: #eae3d5; }
.no-cover i { font-size: 35px; }
.no-cover p { margin: 0; }
.detail-body { display: grid; grid-template-columns: 1.02fr 1fr; gap: 54px; padding: 48px 0 20px; align-items: start; }
.media-section { min-width: 0; position: sticky; top: 24px; }
.main-media { padding: 12px; background: #e9e3d8; border: 1px solid #dcd2bf; }
.media-display { min-height: 340px; display: flex; justify-content: center; align-items: center; background: #f8f5ee; }
.main-image, .main-video { display: block; width: 100%; max-height: 610px; object-fit: contain; }
.image-viewer { width:100%; min-width:0; }
.image-preview-trigger { position:relative; display:block; width:100%; padding:0; border:0; background:transparent; cursor:zoom-in; overflow:hidden; }
.image-preview-trigger .main-image { transition:filter .4s ease; }
.image-preview-hint { position:absolute; right:13px; bottom:13px; display:flex; align-items:center; gap:8px; padding:9px 12px; background:#263b31e8; border:1px solid #cbb68c66; color:#f5e8cf; font:11px/1.5 'PingFang SC',sans-serif; letter-spacing:.1em; pointer-events:none; transition:background-color .3s,border-color .3s; }
.image-preview-trigger:focus-visible { outline:2px solid #a44034; outline-offset:4px; }
.media-caption { display:flex; justify-content:space-between; gap:15px; margin:4px 0 0; padding-top:11px; color:#9b8b70; border-top:1px solid #d9cfbd; font-size:10px; letter-spacing:.1em; }
.artwork-fade-enter-active,.artwork-fade-leave-active { transition:opacity .18s ease; }.artwork-fade-enter-from,.artwork-fade-leave-to { opacity:0; }
.artwork-preview-frame img { display:block; width:100%; max-height:74vh; object-fit:contain; background:#e8e1d4; }
.artwork-preview-frame p { display:flex; justify-content:space-between; flex-wrap:wrap; gap:8px; margin:14px 2px 2px; color:#72664e; font-size:11px; }.artwork-preview-frame p span { color:#a49881; }
.main-video { background: #172d26; min-height: 290px; }
.audio-player { padding: 70px 20px; display: flex; flex-direction: column; align-items: center; width: 100%; gap: 30px; color: #a44034; }
.audio-player i { font-size: 60px; }
.main-audio { max-width: 100%; }
.no-media { min-height: 340px; display: flex; flex-direction: column; justify-content: center; align-items: center; gap: 16px; color: #b3a58a; }
.no-media i { font-size: 40px; }
.no-media p { margin: 0; font-size: 13px; letter-spacing: 2px; }
.media-thumbnails { display: flex; gap: 10px; padding: 16px 0; overflow-x: auto; }
.thumbnail-item { flex: 0 0 76px; height: 66px; padding: 4px; border: 1px solid #d8cfbd; cursor: pointer; background: #fffdf6; }
.thumbnail-item.active { border-color: #a44034; }
.thumbnail-item { appearance:none; transition:border-color .25s,box-shadow .25s; }
.thumbnail-item:focus-visible { outline:2px solid #a44034; outline-offset:3px; }
.thumbnail-item.active { box-shadow:inset 0 0 0 1px #a440344d; }
.thumbnail-item img { display:block; }
@media(hover:hover) and (pointer:fine) { .image-preview-trigger:hover .main-image { filter:brightness(1.035); }.image-preview-trigger:hover .image-preview-hint { background:#a44034e8; border-color:#efc7a58a; }.thumbnail-item:hover { border-color:#ab8d60; box-shadow:0 3px 10px #70593915; } }
@media(prefers-reduced-motion:reduce) { .artwork-fade-enter-active,.artwork-fade-leave-active,.image-preview-trigger .main-image,.image-preview-hint,.thumbnail-item { transition:none; } }
.thumbnail-item img { width: 100%; height: 100%; object-fit: cover; }
.thumbnail-icon { height: 100%; display: grid; place-items: center; color: #a44034; font-size: 22px; }
.info-section { min-width: 0; }
.info-section > div { padding-bottom: 30px; margin-bottom: 30px; border-bottom: 1px solid #dfd6c7; }
.info-section h3 { display: flex; align-items: center; gap: 13px; margin: 0 0 20px; color: #344737; font: 500 23px 'Songti SC', 'STSong', 'SimSun', serif; letter-spacing: 2px; }
.info-section h3::before { content: ''; width: 4px; height: 20px; background: #a44034; }
.summary-text { font: 17px/2.05 'Songti SC', 'STSong', 'SimSun', serif; color: #77674e; margin-bottom: 0; }
.description-content { font-size: 14px; line-height: 2.2; color: #7e796d; text-align: justify; overflow-wrap: anywhere; }
.no-content, .archive-empty { font-size: 13px; color: #a39781; }
.archive-grid { display: grid; grid-template-columns: 76px 1fr; font-size: 12px; line-height: 1.9; margin-bottom: 0; column-gap: 17px; }
.archive-grid dt, .archive-grid dd { padding: 10px 0; margin: 0; border-bottom: 1px dashed #e0d7c8; }
.archive-grid dt { color: #a39276; }
.archive-grid dd { color: #726c60; overflow-wrap: anywhere; }
.archive-grid dd a { color: #a44034; }
.archive-grid .archive-empty { grid-column: 1 / -1; }
.creator-info { color: #8e7e64; display: flex; gap: 10px; align-items: center; }
.creator-info i { font-size: 20px; }
.inheritor-section, .related-section { margin-top: 52px; }
.inheritor-section h2, .related-section h2 { display: flex; gap: 20px; align-items: center; margin: 0 0 30px; color: #314737; font: 500 30px 'Songti SC', 'STSong', 'SimSun', serif; letter-spacing: 3px; }
.inheritor-section h2::after, .related-section h2::after { content: ''; height: 1px; flex: 1; background: #d9cfbd; }
.inheritor-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 22px; }
.inheritor-card { display: flex; align-items: center; flex-wrap: wrap; gap: 17px; padding: 23px; background: #fffcf6; border: 1px solid #e1d8c7; }
.inheritor-avatar { width: 72px; height: 88px; overflow: hidden; display: grid; place-items: center; background: #eae2d4; color: #a49377; }
.inheritor-avatar img { width: 100%; height: 100%; object-fit: cover; }
.inheritor-info { flex: 1; min-width: 70px; }
.inheritor-info h4 { color: #344737; font: 500 23px 'Songti SC', 'STSong', 'SimSun', serif; letter-spacing: 2px; margin-bottom: 8px; }
.inheritor-title, .inheritor-region { font-size: 12px; color: #9a8b72; margin-bottom: 5px; }
.inheritor-card :deep(.ant-btn) { background: transparent; color: #a44034; border: 0; box-shadow: none; padding: 0; font-size: 12px; }
.related-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 24px; }
.loading-container { width: calc(100% - 96px); max-width: 1320px; margin: 0 auto; padding: 50px 0; }
.not-found { text-align: center; padding: 120px 24px; color: #97876b; }
.not-found i { font-size: 45px; margin-bottom: 20px; }
.not-found p { font: 25px 'Songti SC', serif; }
.not-found :deep(.ant-btn) { background: #a44034; border-color: #a44034; border-radius: 0; }
@media (max-width: 1100px) { .detail-body { gap: 30px; } .related-grid { gap: 16px; grid-template-columns: repeat(3, 1fr); } .inheritor-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 800px) {
  .detail-container { width: calc(100% - 48px); padding-bottom: 45px; }
  .header-content { grid-template-columns: 1fr 160px; gap: 25px; }
  .header-cover { height: 175px; }
  .header-breadcrumb { margin-bottom: 28px; }
  .header-meta { gap: 12px; }
  .detail-title { letter-spacing: 2px; }
  .detail-body { grid-template-columns: 1fr; padding-top: 30px; }
  .media-section { position: static; }
  .media-display { min-height: 240px; }
  .related-grid { grid-template-columns: repeat(2, 1fr); }
  .inheritor-section h2, .related-section h2 { font-size: 25px; }
}
@media (max-width: 520px) {
  .header-content { grid-template-columns: 1fr; }
  .header-cover { display: none; }
  .detail-header { padding-top: 24px; }
  .detail-eyebrow { font-size: 9px; letter-spacing: 2px; }
  .inheritor-grid { grid-template-columns: 1fr; }
  .related-grid { gap: 12px; }
  .header-meta { font-size: 11px; }
}
</style>
