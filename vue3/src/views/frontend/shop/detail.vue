<template>
  <div class="product-detail-wrapper">
    <div class="product-detail-page">
      <!-- 加载状态 -->
      <div v-if="loading" class="loading-container">
      <a-skeleton :loading="true" active :paragraph="{ rows: 10 }" />
    </div>

    <!-- 商品详情 -->
    <div v-else-if="product" class="detail-container">
      <!-- 面包屑导航 -->
      <div class="breadcrumb">
        <a-breadcrumb>
          <a-breadcrumb-item>
            <router-link to="/">首页</router-link>
          </a-breadcrumb-item>
          <a-breadcrumb-item>
            <router-link to="/shop">商城</router-link>
          </a-breadcrumb-item>
          <a-breadcrumb-item>{{ product.title }}</a-breadcrumb-item>
        </a-breadcrumb>
      </div>

      <!-- 主体内容 -->
      <div class="detail-body">
        <!-- 左侧：商品图片 -->
        <div class="image-section">
          <!-- 主图展示 -->
          <div class="main-image">
            <img
              v-if="mainImage"
              :src="mainImage.filePath"
              :alt="mainImage.originalName || product.title"
            />
            <div v-else class="no-image">
              <i class="fas fa-image"></i>
              <p>暂无图片</p>
            </div>
          </div>

          <!-- 缩略图列表 -->
          <div v-if="imageList.length > 1" class="image-thumbnails">
            <div
              v-for="(image, index) in imageList"
              :key="image.id"
              class="thumbnail-item"
              :class="{ active: currentImageIndex === index }"
              @click="handleImageChange(index)"
            >
              <img
                :src="image.filePath"
                :alt="image.originalName"
              />
            </div>
          </div>
        </div>

        <!-- 右侧：商品信息 -->
        <div class="info-section">
          <div class="product-header"><span class="product-kicker">CULTURE IN YOUR EVERYDAY LIFE / 非遗文创</span>
            <h1 class="product-title">{{ product.title }}</h1>
            <p v-if="product.subtitle" class="product-subtitle">
              {{ product.subtitle }}
            </p>
            <div class="product-category">
              <a-tag color="blue">{{ product.categoryName }}</a-tag>
            </div>
          </div>

          <div class="product-price-box">
            <div class="price-row">
              <span class="price-label">价格</span>
              <div class="price-value">
                <span class="price-symbol">¥</span>
                <span class="price-number">{{ product.price }}</span>
              </div>
            </div>
            <div class="stock-row">
              <span class="stock-label">库存</span>
              <span class="stock-value" :class="{ 'out-of-stock': product.stock <= 0 }">
                {{ product.stock > 0 ? `${product.stock} 件` : '已售罄' }}
              </span>
            </div>
          </div>

          <div class="purchase-section">
            <div class="quantity-selector">
              <span class="quantity-label">数量</span>
              <a-input-number
                v-model:value="quantity"
                :min="1"
                :max="product.stock"
                :disabled="product.stock <= 0"
              />
            </div>

            <div class="action-buttons">
              <a-button
                type="primary"
                size="large"
                block
                :disabled="product.stock <= 0"
                @click="handleBuyNow"
              >
                <i class="fas fa-bolt"></i>
                立即购买
              </a-button>
            </div>
          </div>

          <div class="product-tips">
            <div class="tip-item">
              <i class="fas fa-shield-alt"></i>
              <span>正品保证</span>
            </div>
            <div class="tip-item">
              <i class="fas fa-truck"></i>
              <span>全国包邮</span>
            </div>
            <div class="tip-item">
              <i class="fas fa-undo"></i>
              <span>7天无理由退换</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 商品详情描述 -->
      <div class="detail-description">
        <a-tabs v-model:activeKey="activeTab">
          <a-tab-pane key="detail" tab="商品详情">
            <div class="description-content">
              <div v-if="product.detail" class="detail-html" v-html="product.detail"></div>
              <div v-else class="no-detail">
                <p>暂无详细描述</p>
              </div>
            </div>
          </a-tab-pane>
          
          <a-tab-pane key="info" tab="商品信息">
            <div class="info-content">
              <a-descriptions bordered :column="{ xs: 1, sm: 2 }">
                <a-descriptions-item label="商品ID">
                  {{ product.id }}
                </a-descriptions-item>
                <a-descriptions-item label="商品分类">
                  {{ product.categoryName }}
                </a-descriptions-item>
                <a-descriptions-item label="商品价格">
                  ¥{{ product.price }}
                </a-descriptions-item>
                <a-descriptions-item label="库存数量">
                  {{ product.stock }} 件
                </a-descriptions-item>
                <a-descriptions-item label="上架时间" :span="2">
                  {{ formatDate(product.createTime) }}
                </a-descriptions-item>
              </a-descriptions>
            </div>
          </a-tab-pane>
        </a-tabs>
      </div>

      <!-- 推荐商品 -->
      <div v-if="recommendProducts.length > 0" class="recommend-section">
        <h2>相关推荐</h2>
        <div class="recommend-grid">
          <div
            v-for="item in recommendProducts"
            :key="item.id"
            class="recommend-card"
            @click="handleProductClick(item.id)"
          >
            <div class="recommend-image">
              <img
                v-if="item.coverFilePath"
                :src="item.coverFilePath"
                :alt="item.title"
              />
              <div v-else class="no-image">
                <i class="fas fa-image"></i>
              </div>
            </div>
            <div class="recommend-info">
              <h3>{{ item.title }}</h3>
              <div class="recommend-price">
                <span class="price-symbol">¥</span>
                <span class="price-value">{{ item.price }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 错误状态 -->
    <div v-else class="error-state">
      <i class="fas fa-exclamation-circle"></i>
      <p>商品不存在或已下架</p>
      <a-button type="primary" @click="$router.push('/shop')">
        返回商城
      </a-button>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { getProductById, getProductRecommendations } from '@/api/ShopProductApi'
import { useUserStore } from '@/store/user'
import { withDisplayYear } from '@/utils/dateUtils'

// ========== 路由 ==========
const route = useRoute()
const router = useRouter()

// ========== 响应式数据 ==========
const loading = ref(false)
const product = ref(null)
const quantity = ref(1)
const activeTab = ref('detail')
const recommendProducts = ref([])
const imageList = ref([])
const currentImageIndex = ref(0)

function formatDate(value) {
  const date = withDisplayYear(value)
  return date ? date.toLocaleString('zh-CN') : '-'
}

// ========== 计算属性 ==========
const mainImage = computed(() => {
  if (imageList.value.length > 0) {
    return imageList.value[currentImageIndex.value]
  }
  // 如果没有图片列表，使用封面
  if (product.value && product.value.coverFilePath) {
    return {
      id: product.value.coverFileId,
      filePath: product.value.coverFilePath,
      originalName: '封面图片',
      type: 'IMG'
    }
  }
  return null
})

// ========== 生命周期 ==========
onMounted(() => {
  fetchProductDetail()
  fetchRecommendProducts()
})

// ========== 方法 ==========
const fetchProductDetail = () => {
  loading.value = true
  const productId = route.params.id
  
  getProductById(productId, {
    onSuccess: (res) => {
      product.value = res
      loading.value = false
      
      // 加载图片列表
      if (res.imageList && res.imageList.length > 0) {
        imageList.value = res.imageList
        currentImageIndex.value = 0
        console.log(`成功加载 ${res.imageList.length} 张商品图片`)
      } else {
        imageList.value = []
        currentImageIndex.value = 0
      }
    },
    onError: (error) => {
      message.error('获取商品详情失败：' + error.message)
      loading.value = false
    }
  })
}

const fetchRecommendProducts = () => {
  const productId = route.params.id
  
  // 使用基于协同过滤的推荐算法获取相关推荐商品
  getProductRecommendations(productId, 4, {
    onSuccess: (res) => {
      recommendProducts.value = res || []
      console.log('推荐商品加载成功，数量:', recommendProducts.value.length)
    },
    onError: (error) => {
      console.warn('推荐商品加载失败:', error)
      // 静默失败，不显示错误提示
      recommendProducts.value = []
    }
  })
}

const handleBuyNow = () => {
  // 检查登录状态
  const userStore = useUserStore()
  if (!userStore.isLoggedIn) {
    message.warning('请先登录')
    router.push('/auth/login')
    return
  }
  
  // 跳转到订单确认页面，携带商品信息
  router.push({
    name: 'OrderConfirm',
    query: {
      productId: product.value.id,
      quantity: quantity.value
    }
  })
}

const handleProductClick = (id) => {
  router.push(`/shop/${id}`)
  // 重新加载商品详情
  fetchProductDetail()
  fetchRecommendProducts()
  // 滚动到顶部
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleImageChange = (index) => {
  currentImageIndex.value = index
}
</script>

<style scoped>
.product-detail-wrapper { color: #3d4237; padding: 32px 0 70px; min-height: 65vh; }
.product-detail-page { width: min(1180px,calc(100% - 96px)); margin: auto; }
.breadcrumb { padding: 0 0 30px; }
.breadcrumb :deep(.ant-breadcrumb) { font-size: 11px; color: #a0957f; }
.breadcrumb :deep(a) { color: #8a846f; }
.detail-body { display: grid; grid-template-columns: minmax(0,1fr) minmax(0,.92fr); gap: 65px; padding-bottom: 50px; border-bottom: 1px solid #cfc1a6; }
.image-section { min-width: 0; }
.main-image { width: 100%; aspect-ratio: 1; padding: 10px; background: #fffdf7; border: 1px solid #dbd0b9; }
.main-image>img { width: 100%; height: 100%; object-fit: cover; background: #eee7d8; }
.no-image { height: 100%; display: flex; flex-direction: column; gap: 15px; justify-content: center; align-items: center; color: #b0a084; background: #eee8dc; }
.no-image i { font-size: 36px; }.no-image p { font-size: 12px; }
.image-thumbnails { display: flex; gap: 12px; overflow-x: auto; padding: 14px 0 5px; }
.thumbnail-item { flex: 0 0 72px; aspect-ratio: 1; padding: 3px; border: 1px solid #ddd2bc; background: #fffdf7; cursor: pointer; transition: border-color .2s; }
.thumbnail-item img { height: 100%; width: 100%; object-fit: cover; }.thumbnail-item.active { border-color: #a33b2e; }.thumbnail-item:hover { border-color: #af9270; }
.info-section { padding-top: 12px; }.product-kicker { font-size: 9px; letter-spacing: .12em; color: #9d8c6f; }
.info-section,.detail-description,.recommend-card { min-width: 0; }.product-title,.product-subtitle,.breadcrumb :deep(.ant-breadcrumb) { overflow-wrap: anywhere; }
.product-header { padding-bottom: 26px; }.product-title { font: 400 33px/1.6 'Songti SC',serif; letter-spacing: .08em; color: #354333; margin: 20px 0 13px; }.product-subtitle { font-size: 12px; line-height: 2.1; color: #8a8676; margin-bottom: 20px; }
.product-category :deep(.ant-tag) { background: transparent; color: #a28559; border-color: #ceb894; font-size: 10px; padding: 2px 9px; }
.product-price-box { padding: 23px 0; border-top: 1px solid #d6c8ad; border-bottom: 1px solid #d6c8ad; background: linear-gradient(90deg,#e4d8bf44,transparent); }
.price-row,.stock-row { display: flex; align-items: center; gap: 30px; }.stock-row { margin-top: 19px; }.price-label,.stock-label,.quantity-label { font-size: 11px; color: #8d826d; min-width: 45px; letter-spacing: .15em; }.price-value { color: #a13a2d; }.price-symbol { font-size: 17px; margin-right: 7px; }.price-number { font: 40px/1 Georgia,serif; }.stock-value { font-size: 11px; color: #6f7e5c; }.stock-value.out-of-stock { color: #a79981; }
.purchase-section { padding-top: 27px; }.quantity-selector { display: flex; align-items: center; gap: 30px; }.quantity-selector :deep(.ant-input-number) { width: 100px; height: 36px; background: #fffdf6; }.quantity-selector :deep(.ant-input-number-input) { height: 34px; }
.action-buttons { margin-top: 25px; max-width: 340px; }.action-buttons :deep(.ant-btn) { height: 48px; letter-spacing: .2em; font: 14px 'Songti SC',serif; }.action-buttons i { margin-right: 10px; font-size: 11px; }
.product-tips { display: flex; flex-wrap: wrap; gap: 18px; margin-top: 25px; }.tip-item { display: flex; align-items: center; gap: 7px; font-size: 9px; color: #a2967e; }.tip-item i { color: #8f9778; font-size: 11px; }
.detail-description { margin-top: 40px; }.detail-description :deep(.ant-tabs-nav) { margin-bottom: 0; }.detail-description :deep(.ant-tabs-tab) { padding: 15px 12px; font: 17px 'Songti SC',serif; letter-spacing: .12em; }.detail-description :deep(.ant-tabs-nav:before) { border-color: #cfc1a6; }
.description-content,.info-content { padding: 35px; background: #fffcf5ad; border: 1px solid #ded2bb; border-top: 0; }.detail-html { max-width: 900px; margin: auto; font-size: 14px; line-height: 2.2; color: #646653; overflow-wrap: anywhere; }.detail-html :deep(img) { display: block; max-width: 100%; height: auto; margin: 25px auto; }.detail-html :deep(h2),.detail-html :deep(h3) { color: #3b4c39; margin: 24px 0 14px; }.no-detail { padding: 30px; text-align: center; color: #a29780; }
.info-content :deep(.ant-descriptions-item-label) { background: #ece4d4!important; color: #7c735f; font-size: 12px; }.info-content :deep(.ant-descriptions-item-content) { font-size: 12px; background: #fefbf3; }.info-content :deep(.ant-descriptions-view) { border-color: #d8c9ad; border-radius: 0; }
.info-content :deep(.ant-descriptions-item-content) { overflow-wrap: anywhere; }.detail-html { overflow-x: auto; }
.recommend-section { padding-top: 48px; }.recommend-section>h2 { font: 26px/1.6 'Songti SC',serif; color: #3b4c38; letter-spacing: .13em; margin: 0 0 25px; }.recommend-section>h2:before { content: ''; display: inline-block; width: 3px; height: 24px; background: #a13b2d; margin-right: 14px; vertical-align: -2px; }.recommend-grid { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 22px; }.recommend-card { cursor: pointer; border: 1px solid #dacdb4; background: #fffcf5; transition: transform .3s,border-color .3s; }.recommend-card:hover { transform: translateY(-4px); border-color: #ac9168; }.recommend-image { aspect-ratio: 1.18; overflow: hidden; }.recommend-image img { width: 100%; height: 100%; object-fit: cover; transition: transform .5s; }.recommend-card:hover img { transform: scale(1.04); }.recommend-info { padding: 18px; }.recommend-info h3 { font: 17px/1.5 'Songti SC',serif; color: #4f5a43; margin: 0 0 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }.recommend-price { color: #a23d2e; }.recommend-price .price-value { font: 22px Georgia,serif; }.recommend-price .price-symbol { font-size: 11px; margin-right: 4px; }
.loading-container { padding: 65px 30px; }.error-state { padding: 100px 25px; text-align: center; color: #9a8c73; }.error-state>i { font-size: 38px; margin-bottom: 20px; }.error-state p { font: 23px 'Songti SC',serif; margin-bottom: 30px; }
@media(max-width:1020px) { .detail-body { gap: 35px; }.product-title { font-size: 28px; }.product-detail-page { width: calc(100% - 60px); } }
@media(max-width:700px) { .product-detail-wrapper { padding: 23px 0 42px; }.product-detail-page { width: calc(100% - 40px); }.breadcrumb { padding-bottom: 22px; }.breadcrumb :deep(.ant-breadcrumb) { font-size: 10px; }.detail-body { grid-template-columns: 1fr; gap: 20px; padding-bottom: 30px; }.main-image { padding: 7px; }.thumbnail-item { flex-basis: 58px; }.info-section { padding-top: 5px; }.product-kicker { font-size: 8px; letter-spacing: .07em; }.product-title { font-size: 26px; margin-top: 14px; }.product-header { padding-bottom: 20px; }.price-number { font-size: 33px; }.product-price-box { padding-block: 21px; }.product-tips { gap: 14px; }.action-buttons { max-width: none; }.detail-description { margin-top: 25px; }.detail-description :deep(.ant-tabs-tab) { font-size: 16px; }.description-content,.info-content { padding: 20px 15px; }.detail-html { font-size: 12px; line-height: 2.1; }.recommend-section { padding-top: 30px; }.recommend-section>h2 { font-size: 22px; }.recommend-grid { grid-template-columns: repeat(2,minmax(0,1fr)); gap: 17px 12px; }.recommend-info { padding: 14px 11px; }.recommend-info h3 { font-size: 15px; }.recommend-price .price-value { font-size: 20px; } }
@media(prefers-reduced-motion:reduce) { .thumbnail-item,.recommend-card,.recommend-image img { transition: none; }.recommend-card:hover,.recommend-card:hover img { transform: none; } }
</style>
