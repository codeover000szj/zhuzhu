<template>
  <div class="shop-page">
    <PortalPageHeader eyebrow="THE CULTURAL DESIGN COLLECTION" title="文创 · 好物" description="把传统带回日常，让器物延续手艺的温度。" mark="好物" image="/images/portal-textile.jpg">
      <div class="search-bar">
        <a-input-search v-model:value="searchKeyword" placeholder="寻找一件心仪的文化好物" size="large" allow-clear @search="handleSearch" @keyup.enter="handleSearch" />
      </div>
    </PortalPageHeader>
    <div class="shop-intro"><span>非遗文创馆 / CURATED OBJECTS</span><p>从传统纹样到当代设计，发现文化与生活相遇的灵感。</p><strong>{{ total }} <small>件在售好物</small></strong></div>

    <!-- 筛选器 -->
    <div class="filter-section">
      <div class="filter-tabs">
        <a-button
          :type="selectedCategoryId === null ? 'primary' : 'default'"
          @click="handleCategoryFilter(null)"
        >
          全部商品
        </a-button>
        <a-button
          v-for="category in categoryList"
          :key="category.id"
          :type="selectedCategoryId === category.id ? 'primary' : 'default'"
          @click="handleCategoryFilter(category.id)"
        >
          {{ category.name }}
        </a-button>
      </div>
      
      <div class="filter-controls">
        <a-select
          v-model:value="priceRange"
          placeholder="价格范围"
          allow-clear
          style="width: 150px"
          @change="handleFilter"
        >
          <a-select-option value="">全部价格</a-select-option>
          <a-select-option value="0-50">¥0 - ¥50</a-select-option>
          <a-select-option value="50-100">¥50 - ¥100</a-select-option>
          <a-select-option value="100-200">¥100 - ¥200</a-select-option>
          <a-select-option value="200-500">¥200 - ¥500</a-select-option>
          <a-select-option value="500+">¥500+</a-select-option>
        </a-select>
        
        <a-select
          v-model:value="sortBy"
          style="width: 120px"
          @change="handleFilter"
        >
          <a-select-option value="create_time">最新上架</a-select-option>
          <a-select-option value="price_asc">价格从低到高</a-select-option>
          <a-select-option value="price_desc">价格从高到低</a-select-option>
        </a-select>

        <a-checkbox v-model:checked="onlyInStock" @change="handleFilter">
          仅显示有货
        </a-checkbox>
      </div>
    </div>

    <!-- 商品网格 -->
    <div class="product-grid">
      <div v-if="loading" class="loading-container">
        <a-skeleton
          v-for="n in 12"
          :key="n"
          active
          :loading="true"
        >
          <template #default>
            <div class="skeleton-card">
              <a-skeleton-image style="width: 100%; height: 240px" />
              <div style="padding: 16px">
                <a-skeleton :paragraph="{ rows: 3 }" />
              </div>
            </div>
          </template>
        </a-skeleton>
      </div>
      
      <div v-else-if="productList.length > 0" class="grid-container">
        <div
          v-for="product in productList"
          :key="product.id"
          class="product-card" role="link" tabindex="0"
          @click="handleProductClick(product.id)" @keydown.enter="handleProductClick(product.id)"
        >
          <div class="product-image">
            <img
              v-if="product.coverFilePath"
              :src="product.coverFilePath"
              :alt="product.title"
            />
            <div v-else class="no-image">
              <i class="fas fa-image"></i>
              <span>暂无图片</span>
            </div>
            
            <!-- 库存标签 -->
            <div v-if="product.stock <= 0" class="stock-badge out-of-stock">
              已售罄
            </div>
            <div v-else-if="product.stock < 10" class="stock-badge low-stock">
              仅剩{{ product.stock }}件
            </div>
          </div>
          
          <div class="product-info">
            <h3 class="product-title">{{ product.title }}</h3>
            <p v-if="product.subtitle" class="product-subtitle">
              {{ product.subtitle }}
            </p>
            <div class="product-category">
              <a-tag color="blue">{{ product.categoryName }}</a-tag>
            </div>
            <div class="product-footer">
              <div class="product-price">
                <span class="price-symbol">¥</span>
                <span class="price-value">{{ product.price }}</span>
              </div>
              <a-button
                type="primary"
                :disabled="product.stock <= 0"
                @click.stop="handleBuyNow(product)"
              >
                <span aria-hidden="true">↗</span>
                {{ product.stock > 0 ? '立即购买' : '已售罄' }}
              </a-button>
            </div>
          </div>
        </div>
      </div>
      
      <div v-else class="empty-state">
        <i class="fas fa-shopping-bag"></i>
        <p>暂无相关商品</p>
        <a-button @click="handleReset">重置筛选</a-button>
      </div>
    </div>

    <!-- 分页 -->
    <div v-if="total > 0" class="pagination-section">
      <a-pagination
        v-model:current="currentPage"
        v-model:pageSize="pageSize"
        :total="total"
        :page-size-options="['12', '24', '48']"
        show-size-changer
        show-total
        @change="handlePageChange"
        @showSizeChange="handleSizeChange"
      >
        <template #buildOptionText="props">
          <span>{{ props.value }} 条/页</span>
        </template>
      </a-pagination>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { getProductPage } from '@/api/ShopProductApi'
import { getEnabledCategories } from '@/api/ShopCategoryApi'
import { useUserStore } from '@/store/user'
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue'

// ========== 路由 ==========
const router = useRouter()

// ========== 响应式数据 ==========
const loading = ref(false)
const productList = ref([])
const categoryList = ref([])
const searchKeyword = ref('')
const selectedCategoryId = ref(null)
const priceRange = ref('')
const sortBy = ref('create_time')
const onlyInStock = ref(false)
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)

// ========== 生命周期 ==========
onMounted(() => {
  fetchCategories()
  fetchProducts()
})

// ========== 方法 ==========
const fetchCategories = () => {
  getEnabledCategories({
    onSuccess: (res) => {
      categoryList.value = res || []
    },
    onError: (error) => {
      message.error('获取分类列表失败：' + error.message)
    }
  })
}

const fetchProducts = () => {
  loading.value = true
  
  const params = {
    page: currentPage.value,
    pageSize: pageSize.value,
    title: searchKeyword.value || null,
    categoryId: selectedCategoryId.value,
    status: 1, // 只显示上架商品
    hasStock: onlyInStock.value ? true : null
  }
  
  // 处理价格范围
  if (priceRange.value) {
    if (priceRange.value === '500+') {
      params.minPrice = 500
    } else {
      const [min, max] = priceRange.value.split('-')
      params.minPrice = parseFloat(min)
      params.maxPrice = parseFloat(max)
    }
  }
  
  // 处理排序
  if (sortBy.value === 'price_asc') {
    params.sortField = 'price'
    params.sortOrder = 'asc'
  } else if (sortBy.value === 'price_desc') {
    params.sortField = 'price'
    params.sortOrder = 'desc'
  } else {
    params.sortField = 'create_time'
    params.sortOrder = 'desc'
  }
  
  getProductPage(params, {
    onSuccess: (res) => {
      productList.value = res.records || []
      total.value = res.total || 0
      loading.value = false
    },
    onError: (error) => {
      message.error('获取商品列表失败：' + error.message)
      loading.value = false
    }
  })
}

const handleSearch = () => {
  currentPage.value = 1
  fetchProducts()
}

const handleCategoryFilter = (categoryId) => {
  selectedCategoryId.value = categoryId
  currentPage.value = 1
  fetchProducts()
}

const handleFilter = () => {
  currentPage.value = 1
  fetchProducts()
}

const handleReset = () => {
  searchKeyword.value = ''
  selectedCategoryId.value = null
  priceRange.value = ''
  sortBy.value = 'create_time'
  onlyInStock.value = false
  currentPage.value = 1
  fetchProducts()
}

const handlePageChange = (page) => {
  currentPage.value = page
  fetchProducts()
  // 滚动到顶部
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleSizeChange = (current, size) => {
  currentPage.value = 1
  pageSize.value = size
  fetchProducts()
}

const handleProductClick = (id) => {
  router.push(`/shop/${id}`)
}

const handleBuyNow = (product) => {
  // 检查登录状态
  const userStore = useUserStore()
  if (!userStore.isLoggedIn) {
    message.warning('请先登录')
    router.push('/auth/login')
    return
  }
  
  // 检查库存
  if (product.stock <= 0) {
    message.warning('该商品已售罄')
    return
  }
  
  // 跳转到订单确认页面，携带商品信息
  router.push({
    name: 'OrderConfirm',
    query: {
      productId: product.id,
      quantity: 1
    }
  })
}
</script>

<style scoped>
.shop-page { min-height: 70vh; color: #363b31; padding-bottom: 72px; }
.search-bar { max-width: 390px; }
.search-bar :deep(.ant-input-affix-wrapper) { min-height: 43px; background: #f8f4e9f2; border-color: #e5dcc8; border-radius: 0; }
.search-bar :deep(.ant-input) { background: transparent; font-size: 12px; color: #464b3c; }
.search-bar :deep(.ant-input-search-button) { height: 43px; color: #fff9e9; background: #9e382c; border-color: #9e382c; border-radius: 0; }
.search-bar :deep(.ant-input-search .ant-input-group .ant-input-group-addon .ant-input-search-button),.search-bar :deep(.ant-input-search-button .anticon) { color: #fff9e9; }
.shop-intro,.filter-section,.product-grid,.pagination-section { width: min(1280px,calc(100% - 96px)); margin-inline: auto; }
.shop-intro { display: flex; align-items: center; gap: 22px; padding: 32px 0 24px; border-bottom: 1px solid #d3c6ad; }
.shop-intro>span { font-size: 10px; color: #8a775b; letter-spacing: .12em; }
.shop-intro p { margin: 0; flex: 1; font: 13px/1.8 'Songti SC',serif; color: #767e6a; }
.shop-intro strong { font: 30px/1 Georgia,serif; color: #9f382c; white-space: nowrap; }
.shop-intro small { font: 10px 'PingFang SC',sans-serif; color: #93836d; margin-left: 5px; }
.filter-section { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 22px; padding: 25px 0 30px; }
.filter-tabs,.filter-controls { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.filter-tabs :deep(.ant-btn) { height: 34px; padding-inline: 18px; border-color: transparent; background: transparent; color: #6a6f5b; }
.filter-tabs :deep(.ant-btn-primary) { color: #f9f1df; background: #334b3d; border-color: #334b3d; }
.filter-tabs :deep(.ant-btn:not(.ant-btn-primary):hover) { color: #9e382c; border-color: #c9b391; }
.filter-controls :deep(.ant-select-selector) { background: #fffbf2a8; font-size: 11px; }
.filter-controls :deep(.ant-checkbox-wrapper) { color: #7c7e6d; font-size: 11px; margin-left: 7px; }
.grid-container,.loading-container { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 30px 24px; }
.product-card { position: relative; overflow: hidden; cursor: pointer; background: #fffdf6; border: 1px solid #ddd3be; transition: transform .35s ease,border-color .35s ease,box-shadow .35s ease; }
.product-card:hover { transform: translateY(-5px); border-color: #b69c75; box-shadow: 0 14px 30px #5c4c2912; }
.product-card:focus-visible { outline: 2px solid #a5865c; outline-offset: 5px; }
.product-image { position: relative; aspect-ratio: 1/1.04; overflow: hidden; background: #eee8db; border-bottom: 1px solid #e9dfcc; }
.product-image img { width: 100%; height: 100%; object-fit: cover; transition: transform .65s ease; }
.product-card:hover .product-image img { transform: scale(1.045); }
.no-image { width: 100%; height: 100%; min-height: 150px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 13px; color: #a99a80; font-size: 11px; }
.no-image i { font-size: 28px; opacity: .5; }
.stock-badge { position: absolute; top: 14px; right: 14px; padding: 7px 10px; background: #fffaf0ec; font-size: 10px; letter-spacing: .07em; color: #927744; }
.stock-badge.out-of-stock { color: #746e60; background: #e7e0d2e8; }
.product-info { padding: 20px 19px 18px; }
.product-title { font: 18px/1.5 'Songti SC',serif; color: #3b4535; margin: 0 0 8px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; letter-spacing: .04em; }
.product-subtitle { color: #9a927f; font-size: 11px; line-height: 1.8; margin: 0 0 13px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }
.product-category { margin-bottom: 20px; }
.product-category :deep(.ant-tag) { border-color: #d9c9aa; background: transparent; color: #a2875d; font-size: 9px; line-height: 20px; padding-inline: 7px; }
.product-footer { display: flex; justify-content: space-between; align-items: center; gap: 10px; padding-top: 17px; border-top: 1px solid #e9e0cd; }
.product-price { white-space: nowrap; color: #a03c2f; }
.price-symbol { font-size: 12px; margin-right: 4px; }
.price-value { font: 25px/1 Georgia,serif; }
.product-footer :deep(.ant-btn) { font-size: 10px; height: 32px; padding-inline: 12px; }
.product-footer :deep(.ant-btn span[aria-hidden]) { margin-right: 4px; }
.empty-state { text-align: center; padding: 100px 20px; color: #9b9078; }
.empty-state>i { font-size: 38px; color: #bcac8f; margin-bottom: 20px; }
.empty-state p { font: 19px 'Songti SC',serif; letter-spacing: .1em; margin-bottom: 25px; }
.pagination-section { display: flex; justify-content: center; padding-top: 46px; margin-top: 35px; border-top: 1px solid #d9cbb0; }
.pagination-section :deep(.ant-pagination) { display: flex; flex-wrap: wrap; justify-content: center; gap: 7px 0; max-width: 100%; }
.skeleton-card { border: 1px solid #e0d5c1; background: #fcf9f0; }
@media(max-width:1180px) { .grid-container,.loading-container { grid-template-columns: repeat(3,minmax(0,1fr)); }.filter-section { gap: 18px; }.filter-controls { margin-left: auto; }.shop-intro { gap: 16px; }.shop-intro p { font-size: 11px; } }
@media(max-width:760px) { .shop-page { padding-bottom: 40px; }.shop-intro,.filter-section,.product-grid,.pagination-section { width: calc(100% - 40px); }.shop-intro { flex-wrap: wrap; padding: 23px 0 19px; gap: 10px; }.shop-intro>span { flex: 1; font-size: 8px; }.shop-intro p { order: 3; width: 100%; flex-basis: 100%; }.shop-intro strong { font-size: 23px; }.shop-intro small { font-size: 8px; }.filter-section { padding-block: 20px; gap: 15px; }.filter-tabs { gap: 4px; }.filter-tabs :deep(.ant-btn) { padding-inline: 12px; height: 31px; font-size: 11px; }.filter-controls { margin: 0; width: 100%; gap: 7px; }.filter-controls :deep(.ant-select) { flex: 1; width: 110px!important; min-width: 95px; }.filter-controls :deep(.ant-checkbox-wrapper) { width: 100%; margin: 3px 0 0; font-size: 10px; }.grid-container,.loading-container { grid-template-columns: repeat(2,minmax(0,1fr)); gap: 18px 12px; }.product-info { padding: 13px 11px; }.product-title { font-size: 15px; }.product-subtitle { font-size: 9px; margin-bottom: 10px; }.product-category { margin-bottom: 13px; }.product-footer { align-items: flex-start; flex-direction: column; gap: 12px; padding-top: 12px; }.price-value { font-size: 23px; }.product-footer :deep(.ant-btn) { width: 100%; height: 29px; font-size: 10px; }.stock-badge { right: 8px; top: 8px; padding: 5px 7px; font-size: 8px; }.pagination-section { padding-top: 28px; overflow-x: auto; }.pagination-section :deep(.ant-pagination) { font-size: 11px; } }
@media(prefers-reduced-motion:reduce) { .product-card,.product-image img { transition: none; }.product-card:hover,.product-card:hover .product-image img { transform: none; } }
</style>
