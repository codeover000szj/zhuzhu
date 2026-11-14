<template>
  <div class="heritage-list-page">
    <PortalPageHeader
      eyebrow="THE DIGITAL COLLECTION"
      title="作品 · 典藏"
      description="循着一件作品，读懂一门技艺；在数字档案中，留住有温度的文化记忆。"
      mark="藏"
      image="/images/portal-textile.jpg"
    >
      <div class="search-bar">
        <a-input-search
          v-model:value="searchKeyword"
          placeholder="寻一件作品，或输入作品名称"
          size="large"
          allow-clear
          @search="handleSearch"
        />
      </div>
    </PortalPageHeader>

    <!-- 筛选器 -->
    <div class="filter-section">
      <div class="filter-tabs">
        <a-button
          v-for="category in ['全部', ...HERITAGE_CATEGORIES]"
          :key="category"
          :type="selectedCategory === category ? 'primary' : 'default'"
          @click="handleCategoryFilter(category)"
        >
          {{ category }}
        </a-button>
      </div>
      
      <div class="filter-controls">
        <a-select
          v-model:value="selectedRegion"
          placeholder="选择地区"
          allow-clear
          style="width: 120px"
          @change="handleFilter"
        >
          <a-select-option value="">
            全部地区
          </a-select-option>
          <a-select-option
            v-for="region in regionList"
            :key="region"
            :value="region"
          >
            {{ region }}
          </a-select-option>
        </a-select>
        
        <a-select
          v-model:value="sortBy"
          style="width: 120px"
          @change="handleFilter"
        >
          <a-select-option value="publish_time">
            最新发布
          </a-select-option>
          <a-select-option value="create_time">
            最新创建
          </a-select-option>
          <a-select-option value="title">
            标题排序
          </a-select-option>
        </a-select>
      </div>
    </div>

    <div class="collection-caption">
      <div><span>ARCHIVE / COLLECTION</span><h2>让文化记忆，有迹可循</h2></div><p>共收录 <strong>{{ total }}</strong> 件作品档案<span>每一件作品，都是一段传承的注脚</span></p>
    </div>

    <!-- 作品网格 -->
    <div class="heritage-grid">
      <div
        v-if="loading"
        class="loading-container"
      >
        <a-skeleton
          v-for="n in 12"
          :key="n"
          active
          :loading="true"
        >
          <template #default>
            <div class="skeleton-card">
              <a-skeleton-image style="width: 100%; height: 200px" />
              <div style="padding: 16px">
                <a-skeleton :paragraph="{ rows: 2 }" />
              </div>
            </div>
          </template>
        </a-skeleton>
      </div>
      
      <div
        v-else-if="heritageList.length > 0"
        class="grid-container"
      >
        <HeritageItemCard
          v-for="item in heritageList"
          :key="item.id"
          :item="item"
          @click="handleItemClick"
        />
      </div>
      
      <div
        v-else
        class="empty-state"
      >
        <i class="fas fa-search" />
        <p>暂无相关作品</p>
        <a-button @click="handleReset">
          重置筛选
        </a-button>
      </div>
    </div>

    <!-- 分页 -->
    <div
      v-if="total > 0"
      class="pagination-section"
    >
      <a-pagination
        :current="currentPage"
        :page-size="pageSize"
        :total="total"
        :page-size-options="['12', '24', '48']"
        show-size-changer
        :show-total="count => `共 ${count} 件作品`"
        @change="handlePaginationChange"
      >
        <template #buildOptionText="props">
          <span>{{ props.value }} 条/页</span>
        </template>
      </a-pagination>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { message } from 'ant-design-vue'
import { 
  getHeritageItemPage, 
  HERITAGE_CATEGORIES
} from '@/api/HeritageApi'
import HeritageItemCard from '@/components/common/HeritageItemCard.vue'
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'

// ========== 路由 ==========
const router = useRouter()
const route = useRoute()

// 首页采用完整门类名称，作品档案沿用现有数据中的类别名称。
const categoryAliases = {
  '民间文学': '文学',
  '传统音乐': '音乐',
  '传统舞蹈': '舞蹈',
  '传统戏剧': '戏曲',
  '传统美术': '手工艺',
  '传统技艺': '手工艺',
  '传统医药': '医药',
  '民俗礼仪': '民俗'
}

function resolveCategory(value) {
  const category = Array.isArray(value) ? value[0] : value
  const normalized = categoryAliases[category] || category
  return HERITAGE_CATEGORIES.includes(normalized) ? normalized : '全部'
}

function resolveTitle(value) {
  return String((Array.isArray(value) ? value[0] : value) || '').trim()
}

// ========== 响应式数据 ==========
const loading = ref(false)
const searchKeyword = ref(resolveTitle(route.query.title))
const selectedCategory = ref(resolveCategory(route.query.category))
const selectedRegion = ref(resolveTitle(route.query.region))
const sortBy = ref('publish_time')
const currentPage = ref(1)
const pageSize = ref(12)

const heritageList = ref([])
const total = ref(0)
let latestRequestId = 0

// 地区列表（可以从API获取或配置）
const regionList = ref([
  '北京', '上海', '广东', '江苏', '浙江', '山东', '河南', '湖北', '湖南', '四川',
  '陕西', '山西', '河北', '辽宁', '吉林', '黑龙江', '安徽', '江西', '福建', '广西',
  '海南', '重庆', '贵州', '云南', '西藏', '甘肃', '青海', '宁夏', '新疆', '内蒙古',
  '天津', '香港', '澳门', '台湾'
])

// ========== 计算属性 ==========
const searchParams = computed(() => {
  return {
    currentPage: currentPage.value,
    size: pageSize.value,
    title: searchKeyword.value,
    category: selectedCategory.value === '全部' ? '' : selectedCategory.value,
    region: selectedRegion.value,
    status: 2, // 只显示已发布的作品
    orderBy: sortBy.value,
    orderDirection: 'desc'
  }
})

// ========== 方法 ==========

/**
 * 获取作品列表
 */
function fetchHeritageList() {
  const requestId = ++latestRequestId
  loading.value = true
  
  getHeritageItemPage(searchParams.value, {
    onSuccess: (res) => {
      if (requestId !== latestRequestId) return
      heritageList.value = res.records || []
      total.value = res.total || 0
      loading.value = false
    },
    onError: () => {
      if (requestId !== latestRequestId) return
      message.error('获取作品列表失败')
      loading.value = false
    }
  })
}

/**
 * 搜索处理
 */
function handleSearch() {
  currentPage.value = 1
  router.replace({
    query: { ...route.query, title: searchKeyword.value.trim() || undefined }
  })
  fetchHeritageList()
}

/**
 * 类别筛选
 */
function handleCategoryFilter(category) {
  selectedCategory.value = category
  currentPage.value = 1
  router.replace({
    query: { ...route.query, category: category === '全部' ? undefined : category }
  })
  fetchHeritageList()
}

/**
 * 筛选处理
 */
function handleFilter() {
  currentPage.value = 1
  router.replace({ query: { ...route.query, region: selectedRegion.value || undefined } })
  fetchHeritageList()
}

/**
 * 重置筛选
 */
function handleReset() {
  searchKeyword.value = ''
  selectedCategory.value = '全部'
  selectedRegion.value = ''
  sortBy.value = 'publish_time'
  currentPage.value = 1
  router.replace({ query: { ...route.query, category: undefined, title: undefined, region: undefined } })
  fetchHeritageList()
}

/**
 * 分页或每页数量改变时同步请求参数，避免两个事件重复请求。
 */
function handlePaginationChange(page, size) {
  currentPage.value = size === pageSize.value ? page : 1
  pageSize.value = size
  fetchHeritageList()
}

/**
 * 作品点击处理
 */
function handleItemClick(item) {
  router.push(`/heritage/${item.id}`)
}

// ========== 生命周期 ==========
watch(() => route.query.category, (category) => {
  const nextCategory = resolveCategory(category)
  if (nextCategory === selectedCategory.value) return
  selectedCategory.value = nextCategory
  currentPage.value = 1
  fetchHeritageList()
})

watch(() => route.query.title, (title) => {
  const nextTitle = resolveTitle(title)
  if (nextTitle === searchKeyword.value.trim()) return
  searchKeyword.value = nextTitle
  currentPage.value = 1
  fetchHeritageList()
})

watch(() => route.query.region, (region) => {
  const nextRegion = resolveTitle(region)
  if (nextRegion === selectedRegion.value) return
  selectedRegion.value = nextRegion
  currentPage.value = 1
  fetchHeritageList()
})

onMounted(() => {
  fetchHeritageList()
})
</script>

<style scoped>
.heritage-list-page { min-height: 100vh; padding-bottom: 64px; background: #f7f4ec; color: #353b33; }
.search-bar { width: min(440px, 100%); margin-top: 28px; }
.search-bar :deep(.ant-input-affix-wrapper), .search-bar :deep(.ant-input-group-addon .ant-btn) { border-radius: 0; border-color: #b9bcae; background: #ffffffe6; height: 43px; }
.filter-section { width: min(1320px, calc(100% - 96px)); margin: 0 auto; padding: 31px 0 25px; display: flex; gap: 24px; justify-content: space-between; align-items: center; border-bottom: 1px solid #d7cebb; }
.filter-tabs { display: flex; align-items: center; flex-wrap: wrap; gap: 8px 6px; }
.filter-tabs :deep(.ant-btn) { border: 0; border-radius: 0; box-shadow: none; padding: 5px 13px; height: 34px; background: transparent; color: #7f796b; }
.filter-tabs :deep(.ant-btn-primary) { color: #fff; background: #a43228; }
.filter-tabs :deep(.ant-btn:not(.ant-btn-primary):hover) { color: #a43228; background: #eae2d3; }
.filter-controls { display: flex; flex-shrink: 0; gap: 12px; }
.filter-controls :deep(.ant-select-selector) { background: transparent; border-radius: 0; border-color: #c9bfab; font-size: 12px; }
.collection-caption { width: min(1320px,calc(100% - 96px)); margin: 55px auto 33px; display: flex; align-items: flex-end; justify-content: space-between; gap: 24px; }
.collection-caption span { display: block; color: #a38963; font: 10px/1.8 Arial,sans-serif; letter-spacing: .18em; }
.collection-caption h2 { margin: 10px 0 0; font: 400 25px/1.5 'Songti SC','SimSun',serif; letter-spacing: .12em; }
.collection-caption p { margin: 0 0 3px; text-align: right; font-size: 12px; color: #8f846f; }
.collection-caption p strong { color: #a43228; font: 25px Georgia,serif; padding-inline: 6px; }
.collection-caption p span { margin-top: 7px; font: 10px/1.7 'PingFang SC',sans-serif; letter-spacing: .04em; }
.heritage-grid { width: min(1320px,calc(100% - 96px)); margin: 0 auto; }
.grid-container, .loading-container { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 36px 27px; }
.skeleton-card { border: 1px solid #d8cfbc; background: #fffdf6; }
.empty-state { padding: 90px 20px; text-align: center; color: #9b907e; }.empty-state i { font-size: 40px; color: #c0b39b; }.empty-state p { margin: 19px 0 26px; }
.pagination-section { width: min(1320px,calc(100% - 96px)); border-top: 1px solid #d7cebb; margin: 48px auto 0; padding-top: 35px; display: flex; justify-content: center; }
.pagination-section :deep(.ant-pagination-item), .pagination-section :deep(.ant-select-selector) { border-radius: 0; background: transparent; }.pagination-section :deep(.ant-pagination-item-active) { border-color: #a43228; background: #a43228; }.pagination-section :deep(.ant-pagination-item-active a) { color: #fff; }
@media(max-width:1100px) { .filter-section { flex-wrap: wrap; }.grid-container,.loading-container { grid-template-columns: repeat(3,minmax(0,1fr)); gap: 30px 20px; } }
@media(max-width:800px) { .filter-section,.collection-caption,.heritage-grid,.pagination-section { width: calc(100% - 48px); }.grid-container,.loading-container { grid-template-columns: repeat(2,minmax(0,1fr)); }.collection-caption { margin-top: 39px; }.collection-caption h2 { font-size: 22px; } }
@media(max-width:540px) { .heritage-list-page { padding-bottom: 45px; }.filter-section { padding: 23px 0; gap: 17px; }.filter-tabs { gap: 5px; }.filter-tabs :deep(.ant-btn) { padding-inline: 10px; height: 31px; font-size: 11px; }.filter-controls { width: 100%; }.filter-controls :deep(.ant-select) { flex: 1; }.collection-caption { align-items: flex-start; margin-bottom: 25px; }.collection-caption h2 { max-width: 165px; font-size: 21px; }.collection-caption>p { max-width: 130px; font-size: 10px; }.collection-caption p span { font-size: 9px; }.grid-container,.loading-container { gap: 27px 14px; }.pagination-section { overflow-x: auto; justify-content: flex-start; }.search-bar { margin-top: 20px; } }
</style>
