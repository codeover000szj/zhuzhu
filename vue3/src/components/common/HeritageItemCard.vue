<template>
  <div
    class="heritage-item-card"
    :class="{ 'is-clickable': clickable }"
    :role="clickable ? 'link' : undefined"
    :tabindex="clickable ? 0 : undefined"
    @click="handleCardClick"
    @keydown.enter.self="handleCardClick"
  >
    <!-- 封面图片 -->
    <div class="card-cover">
      <img 
        v-if="item.coverImage" 
        :src="item.coverImage" 
        :alt="item.title"
        class="cover-image"
      >
      <div
        v-else
        class="no-image"
      >
        <i class="fas fa-image" />
        <span>暂无封面</span>
      </div>
      
      <!-- 状态标签 -->
      <div
        class="status-tag"
        :class="statusClass"
      >
        {{ item.statusName || getStatusName(item.status) }}
      </div>
    </div>
    
    <!-- 内容区域 -->
    <div class="card-content">
      <!-- 标题 -->
      <h3
        class="item-title"
        :title="item.title"
      >
        {{ item.title }}
      </h3>
      
      <!-- 类别和地区 -->
      <div class="item-meta">
        <span
          v-if="item.category"
          class="meta-tag category"
        >
          <i class="fas fa-tag" />
          {{ item.category }}
        </span>
        <span
          v-if="item.region"
          class="meta-tag region"
        >
          <i class="fas fa-map-marker-alt" />
          {{ item.region }}
        </span>
      </div>
      
      <!-- 摘要 -->
      <p
        v-if="item.summary"
        class="item-summary"
      >
        {{ item.summary }}
      </p>
      
      <!-- 底部信息 -->
      <div class="card-footer">
        <div class="time-info">
          <i class="fas fa-clock" />
          <span>{{ formatDate(item.createTime) }}</span>
        </div>
        <span
          v-if="clickable && !showActions"
          class="archive-link"
        >查看档案 <span aria-hidden="true">↗</span></span>
      </div>
      
      <!-- 操作按钮 -->
      <div
        v-if="showActions"
        class="card-actions"
      >
        <a-space>
          <a-button 
            v-if="canEdit" 
            type="primary" 
            size="small" 
            @click.stop="handleEdit"
          >
            编辑
          </a-button>
          <a-button 
            v-if="canPublish" 
            type="primary"
            size="small" 
            @click.stop="handlePublish"
          >
            发布
          </a-button>
          <a-button 
            v-if="canOffline" 
            type="default"
            size="small" 
            @click.stop="handleOffline"
          >
            下架
          </a-button>
          <a-button 
            v-if="canDelete" 
            danger
            size="small" 
            @click.stop="handleDelete"
          >
            删除
          </a-button>
        </a-space>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import DateUtils from '@/utils/dateUtils'

// ========== 组件属性 ==========
const props = defineProps({
  // 作品数据
  item: {
    type: Object,
    required: true
  },
  // 是否显示操作按钮
  showActions: {
    type: Boolean,
    default: false
  },
  // 是否可点击
  clickable: {
    type: Boolean,
    default: true
  }
})

// ========== 事件定义 ==========
const emit = defineEmits([
  'click',
  'edit',
  'publish',
  'offline',
  'delete'
])

// ========== 计算属性 ==========

// 状态样式类
const statusClass = computed(() => {
  const statusMap = {
    0: 'draft',     // 草稿
    1: 'pending',   // 待审
    2: 'published', // 已发布
    3: 'offline'    // 下架
  }
  return statusMap[props.item.status] || 'draft'
})

// 是否可以编辑
const canEdit = computed(() => {
  return props.item.status === 0 || props.item.status === 1 // 草稿或待审
})

// 是否可以发布
const canPublish = computed(() => {
  return props.item.status === 0 || props.item.status === 1 // 草稿或待审
})

// 是否可以下架
const canOffline = computed(() => {
  return props.item.status === 2 // 已发布
})

// 是否可以删除
const canDelete = computed(() => {
  return props.item.status === 0 || props.item.status === 3 // 草稿或下架
})

// ========== 方法 ==========

/**
 * 获取状态名称
 */
function getStatusName(status) {
  const statusMap = {
    0: '草稿',
    1: '待审',
    2: '已发布',
    3: '下架'
  }
  return statusMap[status] || '未知'
}

/**
 * 格式化日期
 */
function formatDate(dateStr) {
  if (!dateStr) return ''
  try {
    return DateUtils.formatDate(dateStr)
  } catch (error) {
    return ''
  }
}

/**
 * 处理卡片点击
 */
function handleCardClick() {
  if (props.clickable) {
    emit('click', props.item)
  }
}

/**
 * 处理编辑
 */
function handleEdit() {
  emit('edit', props.item)
}

/**
 * 处理发布
 */
function handlePublish() {
  emit('publish', props.item)
}

/**
 * 处理下架
 */
function handleOffline() {
  emit('offline', props.item)
}

/**
 * 处理删除
 */
function handleDelete() {
  emit('delete', props.item)
}
</script>

<style scoped>
.heritage-item-card {
  height: 100%;
  min-width: 0;
  overflow: hidden;
  background: #fffdf9;
  border: 1px solid #e5ddd0;
  transition: transform .35s ease, box-shadow .35s ease, border-color .35s ease;
}
.is-clickable { cursor: pointer; }
.is-clickable:hover, .is-clickable:focus-visible {
  transform: translateY(-6px);
  border-color: #bba28a;
  box-shadow: 0 16px 32px #3c302412;
}
.is-clickable:focus-visible { outline: 2px solid #a43b32; outline-offset: 4px; }
.card-cover { position: relative; height: 220px; margin: 9px 9px 0; overflow: hidden; background: #e8e0d3; }
.cover-image { width: 100%; height: 100%; object-fit: cover; transition: transform .7s ease; }
.is-clickable:hover .cover-image { transform: scale(1.045); }
.no-image { height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; color: #998975; background: #ede7dc; }
.no-image i { font-size: 40px; }
.status-tag { position: absolute; top: 12px; right: 12px; padding: 5px 10px; font-size: 11px; letter-spacing: 1px; background: #fffdf3ed; color: #635d50; border: 1px solid #ffffff80; }
.status-tag.published { background: #203e36e8; color: #fffdf5; }
.status-tag.pending { background: #9a783be8; color: #fff; }
.status-tag.offline { background: #a4483ae8; color: #fff; }
.card-content { padding: 23px 20px 18px; }
.item-title { margin: 0 0 14px; font: 600 23px/1.5 'Songti SC', 'STSong', 'SimSun', serif; color: #2e3a33; letter-spacing: 1px; display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
.item-meta { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 15px; }
.meta-tag { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; color: #8b7d6a; }
.meta-tag.category { color: #a43b32; }
.meta-tag i { font-size: 10px; opacity: .65; }
.item-summary { min-height: 48px; margin: 0 0 20px; font-size: 13px; color: #8b8579; line-height: 1.85; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.card-footer { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 8px; padding-top: 15px; border-top: 1px solid #ede6db; font-size: 10px; color: #a79d8d; }
.time-info { display: flex; align-items: center; gap: 5px; }
.archive-link { color: #7e4639; white-space: nowrap; font-size: 11px; }
.archive-link span { margin-left: 6px; }
.card-actions { padding-top: 16px; }
.card-actions :deep(.ant-space) { flex-wrap: wrap; }
@media (max-width: 768px) {
  .card-cover { height: 175px; margin: 6px 6px 0; }
  .card-content { padding: 16px 13px; }
  .item-title { font-size: 20px; margin-bottom: 10px; }
  .item-meta { gap: 5px; }
  .item-summary { font-size: 12px; }
  .time-info i { display: none; }
  .archive-link { font-size: 10px; }
}
@media (prefers-reduced-motion: reduce) { .heritage-item-card, .cover-image { transition: none; } }
</style>
