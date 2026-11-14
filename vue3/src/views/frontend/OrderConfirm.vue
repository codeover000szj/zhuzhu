<template>
  <div class="order-confirm-wrapper">
    <div class="order-confirm-page">
      <header class="page-header"><div><span class="page-eyebrow">COMPLETE YOUR COLLECTION</span><h1>确认 · 订单</h1><p>核对收货信息，让心仪的好物来到身边。</p></div><span class="order-step"><b>01</b> 确认信息 <i>—</i> <b>02</b> 完成支付</span></header>

      <!-- 加载状态 -->
      <div v-if="loading" class="loading-container">
      <a-skeleton :loading="true" active :paragraph="{ rows: 8 }" />
    </div>

    <!-- 订单内容 -->
    <div v-else class="order-content">
      <!-- 收货地址 -->
      <a-card title="收货地址" class="section-card">
        <template #extra>
          <a-button type="link" @click="showAddressModal = true">
            <i class="fas fa-plus"></i>
            新增地址
          </a-button>
        </template>

        <div v-if="addressList.length === 0" class="empty-state">
          <i class="fas fa-map-marker-alt"></i>
          <p>暂无收货地址，请先添加地址</p>
          <a-button type="primary" @click="showAddressModal = true">
            添加收货地址
          </a-button>
        </div>

        <a-radio-group v-else v-model:value="selectedAddressId" class="address-list">
          <div
            v-for="addr in addressList"
            :key="addr.id"
            class="address-item"
            :class="{ 'selected': selectedAddressId === addr.id }"
            @click="selectedAddressId = addr.id"
          >
            <a-radio :value="addr.id">
              <div class="address-info">
                <div class="address-header">
                  <span class="receiver-name">{{ addr.receiver }}</span>
                  <span class="receiver-phone">{{ addr.phone }}</span>
                  <a-tag v-if="addr.isDefault" color="blue">默认地址</a-tag>
                </div>
                <div class="address-detail">
                  {{ addr.province }} {{ addr.city }} {{ addr.district }} {{ addr.detail }}
                </div>
              </div>
            </a-radio>
          </div>
        </a-radio-group>
      </a-card>

      <!-- 商品信息 -->
      <a-card title="商品信息" class="section-card">
        <div v-if="product" class="product-info">
          <div class="product-image">
            <img v-if="product.coverFilePath" :src="product.coverFilePath" :alt="product.title" />
            <div v-else class="no-image">
              <i class="fas fa-image"></i>
            </div>
          </div>
          <div class="product-details">
            <h3>{{ product.title }}</h3>
            <p class="product-category">{{ product.categoryName }}</p>
            <div class="product-price-row">
              <span class="price-label">单价：</span>
              <span class="price-value">¥{{ product.price }}</span>
            </div>
            <div class="product-quantity-row">
              <span class="quantity-label">数量：</span>
              <span class="quantity-value">{{ orderQuantity }}</span>
            </div>
          </div>
        </div>
      </a-card>

      <!-- 订单备注 -->
      <a-card title="订单备注" class="section-card">
        <a-textarea
          v-model:value="orderRemark"
          placeholder="选填，请输入订单备注信息"
          :rows="3"
          :maxlength="200"
          show-count
        />
      </a-card>

      <!-- 订单金额 -->
      <a-card class="section-card amount-card">
        <div class="amount-row">
          <span class="amount-label">商品金额：</span>
          <span class="amount-value">¥{{ totalAmount }}</span>
        </div>
        <div class="amount-row total-row">
          <span class="amount-label">应付总额：</span>
          <span class="amount-value total-amount">¥{{ totalAmount }}</span>
        </div>
      </a-card>

      <!-- 提交订单 -->
      <div class="submit-section">
        <p class="payment-hint">提交后进入订单详情，可继续本地演示支付；演示不会产生真实扣款。</p>
        <a-button
          type="primary"
          size="large"
          :loading="submitting"
          :disabled="!selectedAddressId"
          @click="handleSubmitOrder"
        >
          提交订单并继续
        </a-button>
      </div>
    </div>

    <!-- 新增地址弹窗 -->
    <a-modal
      v-model:open="showAddressModal"
      title="新增收货地址"
      :width="600"
      @ok="handleAddAddress"
      @cancel="resetAddressForm"
    >
      <a-form
        :model="addressForm"
        :label-col="{ span: 5 }"
        :wrapper-col="{ span: 19 }"
      >
        <a-form-item label="收货人" required>
          <a-input v-model:value="addressForm.receiver" placeholder="请输入收货人姓名" />
        </a-form-item>
        <a-form-item label="联系电话" required>
          <a-input v-model:value="addressForm.phone" placeholder="请输入联系电话" />
        </a-form-item>
        <a-form-item label="省份" required>
          <a-input v-model:value="addressForm.province" placeholder="请输入省份" />
        </a-form-item>
        <a-form-item label="城市" required>
          <a-input v-model:value="addressForm.city" placeholder="请输入城市" />
        </a-form-item>
        <a-form-item label="区/县" required>
          <a-input v-model:value="addressForm.district" placeholder="请输入区/县" />
        </a-form-item>
        <a-form-item label="详细地址" required>
          <a-textarea
            v-model:value="addressForm.detail"
            placeholder="请输入详细地址"
            :rows="3"
          />
        </a-form-item>
        <a-form-item label="设为默认">
          <a-switch v-model:checked="addressForm.isDefault" />
        </a-form-item>
      </a-form>
    </a-modal>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { getProductById } from '@/api/ShopProductApi'
import { getUserAddressList, createAddress } from '@/api/AddressApi'
import { createOrder } from '@/api/OrderApi'

// ========== 路由 ==========
const route = useRoute()
const router = useRouter()

// ========== 响应式数据 ==========
const loading = ref(true)
const submitting = ref(false)
const product = ref(null)
const orderQuantity = ref(1)
const addressList = ref([])
const selectedAddressId = ref(null)
const orderRemark = ref('')
const showAddressModal = ref(false)

// 新增地址表单
const addressForm = ref({
  receiver: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: false
})

// ========== 计算属性 ==========
const totalAmount = computed(() => {
  if (!product.value) return '0.00'
  return (product.value.price * orderQuantity.value).toFixed(2)
})

// ========== 生命周期 ==========
onMounted(() => {
  const productId = route.query.productId
  const quantity = route.query.quantity

  if (!productId || !quantity) {
    message.error('订单信息不完整')
    router.push('/shop')
    return
  }

  orderQuantity.value = parseInt(quantity)
  fetchProductDetail(productId)
  fetchAddressList()
})

// ========== 方法 ==========
const fetchProductDetail = (productId) => {
  getProductById(productId, {
    onSuccess: (res) => {
      product.value = res
      loading.value = false
    },
    onError: (error) => {
      message.error('获取商品信息失败：' + error.message)
      loading.value = false
    }
  })
}

const fetchAddressList = () => {
  getUserAddressList({
    onSuccess: (res) => {
      addressList.value = res || []
      // 自动选择默认地址
      const defaultAddr = addressList.value.find(addr => addr.isDefault)
      if (defaultAddr) {
        selectedAddressId.value = defaultAddr.id
      } else if (addressList.value.length > 0) {
        selectedAddressId.value = addressList.value[0].id
      }
    },
    onError: (error) => {
      message.error('获取地址列表失败：' + error.message)
    }
  })
}

const handleAddAddress = () => {
  // 验证表单
  if (!addressForm.value.receiver || !addressForm.value.phone ||
      !addressForm.value.province || !addressForm.value.city ||
      !addressForm.value.district || !addressForm.value.detail) {
    message.warning('请填写完整的地址信息')
    return
  }

  createAddress(addressForm.value, {
    successMsg: '地址添加成功',
    onSuccess: () => {
      showAddressModal.value = false
      resetAddressForm()
      fetchAddressList()
    },
    onError: (error) => {
      message.error('添加地址失败：' + error.message)
    }
  })
}

const resetAddressForm = () => {
  addressForm.value = {
    receiver: '',
    phone: '',
    province: '',
    city: '',
    district: '',
    detail: '',
    isDefault: false
  }
}

const handleSubmitOrder = () => {
  if (!selectedAddressId.value) {
    message.warning('请选择收货地址')
    return
  }

  submitting.value = true

  const orderData = {
    productId: product.value.id,
    quantity: orderQuantity.value,
    addressId: selectedAddressId.value,
    remark: orderRemark.value || null
  }

  createOrder(orderData, {
    successMsg: '订单提交成功',
    onSuccess: (res) => {
      submitting.value = false
      // 跳转到订单详情页
      router.push(`/orders/${res.id}`)
    },
    onError: (error) => {
      message.error('订单提交失败：' + error.message)
      submitting.value = false
    }
  })
}
</script>

<style scoped>
.order-confirm-wrapper { padding: 44px 0 70px; min-height: 65vh; color: #46503d; }
.order-confirm-page { width: min(980px,calc(100% - 80px)); margin: auto; }
.page-header { display: flex; align-items: center; justify-content: space-between; gap: 25px; padding-bottom: 30px; margin-bottom: 30px; border-bottom: 1px solid #cabb9f; }
.page-eyebrow { font-size: 9px; letter-spacing: .2em; color: #a18a64; }
.page-header h1 { font: 34px/1.6 'Songti SC',serif; letter-spacing: .14em; margin: 10px 0 7px; color: #364b38; }
.page-header p { font-size: 11px; color: #928971; margin: 0; letter-spacing: .07em; }
.order-step { color: #9a8b6f; font-size: 10px; white-space: nowrap; }.order-step b { font: 17px Georgia,serif; color: #a33e2d; margin-right: 5px; }.order-step i { font-style: normal; margin: 0 12px; color: #b8a484; }
.order-content { display: flex; flex-direction: column; gap: 23px; }
.section-card { background: #fffdf6e8; border-color: #d8cbb3; border-radius: 1px; }
.section-card :deep(.ant-card-head) { min-height: 60px; padding: 0 28px; border-color: #e1d6c0; background: #eae2d340; }.section-card :deep(.ant-card-head-title) { font: 19px 'Songti SC',serif; letter-spacing: .13em; color: #485640; }.section-card :deep(.ant-card-head-title):before { content: ''; display: inline-block; width: 3px; height: 16px; background: #a23b2d; margin-right: 12px; vertical-align: -1px; }.section-card :deep(.ant-card-body) { padding: 26px 28px; }.section-card :deep(.ant-btn-link) { color: #9c7b4f; font-size: 11px; }.section-card :deep(.ant-btn-link i) { margin-right: 5px; font-size: 9px; }
.address-list { width: 100%; display: grid; gap: 12px; grid-template-columns: repeat(2,minmax(0,1fr)); }.address-item { padding: 19px 15px; border: 1px solid #dfd4be; background: #fbf8ef; cursor: pointer; transition: border-color .25s,background .25s; }.address-item.selected { border-color: #a07b4b; background: #f1e8d4; }.address-item:hover { border-color: #b49a73; }.address-item :deep(.ant-radio-wrapper) { width: 100%; align-items: flex-start; font-size: 12px; }.address-item :deep(.ant-radio) { margin-top: 2px; }.address-info { padding-left: 7px; }.address-header { display: flex; flex-wrap: wrap; align-items: center; gap: 9px; margin-bottom: 10px; }.receiver-name { font: 17px 'Songti SC',serif; color: #42513a; }.receiver-phone { color: #8c826d; font-size: 11px; }.address-header :deep(.ant-tag) { font-size: 8px; line-height: 17px; background: #faf5e7; color: #9b7846; border-color: #d3bd99; }.address-detail { font-size: 11px; color: #8c8674; line-height: 1.9; }
.product-info { display: flex; align-items: center; gap: 28px; }.product-image { width: 140px; aspect-ratio: 1; flex-shrink: 0; padding: 5px; border: 1px solid #e0d5bf; background: #f2eadc; }.product-image img { width: 100%; height: 100%; object-fit: cover; }.no-image { height: 100%; display: flex; align-items: center; justify-content: center; color: #bcab8e; font-size: 30px; }.product-details h3 { font: 22px/1.5 'Songti SC',serif; color: #45533d; margin: 0 0 9px; letter-spacing: .07em; }.product-category { color: #a28a65; font-size: 10px; margin-bottom: 15px; }.product-price-row,.product-quantity-row { display: inline-flex; align-items: baseline; gap: 10px; margin-right: 30px; }.price-label,.quantity-label { font-size: 11px; color: #9d927b; }.price-value { font: 24px Georgia,serif; color: #a2392b; }.quantity-value { color: #757e65; font-size: 13px; }
.product-details,.address-item,.address-info { min-width: 0; overflow-wrap: anywhere; }.address-item :deep(.ant-radio-wrapper) { margin-inline-end: 0; }.address-item :deep(.ant-radio-wrapper>span:last-child) { min-width: 0; }
.section-card :deep(textarea.ant-input) { background: #fbf8f0; border-color: #ddd0b7; font-size: 12px; padding: 14px; line-height: 1.9; }.section-card :deep(.ant-input-textarea-show-count:after) { font-size: 10px; color: #ab9c80; }
.amount-card { background: #eee5d4; }.amount-card :deep(.ant-card-body) { padding-block: 25px; }.amount-row { display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #8a7b62; }.amount-value { font: 22px Georgia,serif; color: #657258; }.total-row { margin-top: 20px; padding-top: 20px; border-top: 1px solid #cdbb98; }.total-row .amount-label { font: 19px 'Songti SC',serif; letter-spacing: .1em; color: #596145; }.total-amount { font-size: 36px; color: #a23a2b; }
.submit-section { display: flex; align-items: center; justify-content: flex-end; flex-wrap: wrap; gap: 16px; padding-top: 5px; }.payment-hint { margin: 0 auto 0 0; color: #92866e; font-size: 11px; line-height: 1.8; }.submit-section :deep(.ant-btn) { min-width: 225px; height: 47px; font: 15px 'Songti SC',serif; letter-spacing: .18em; }
.empty-state { padding: 30px 15px; text-align: center; color: #9b8d71; }.empty-state>i { font-size: 30px; color: #b3a184; margin-bottom: 17px; }.empty-state p { font-size: 12px; margin-bottom: 22px; }.loading-container { padding: 35px; background: #fffcf3; border: 1px solid #daceb5; }
@media(max-width:720px) { .order-confirm-wrapper { padding: 30px 0 40px; }.order-confirm-page { width: calc(100% - 36px); }.page-header { align-items: flex-start; flex-direction: column; gap: 22px; padding-bottom: 24px; margin-bottom: 22px; }.page-eyebrow { font-size: 8px; }.page-header h1 { font-size: 28px; }.page-header p { font-size: 10px; }.order-step { font-size: 9px; }.order-step b { font-size: 15px; }.section-card :deep(.ant-card-head) { padding-inline: 17px; min-height: 55px; }.section-card :deep(.ant-card-head-title) { font-size: 17px; }.section-card :deep(.ant-card-body) { padding: 20px 17px; }.address-list { grid-template-columns: 1fr; }.address-item { padding: 16px 12px; }.product-info { gap: 16px; align-items: flex-start; }.product-image { width: 100px; }.product-details h3 { font-size: 18px; }.product-category { margin-bottom: 7px; }.product-price-row,.product-quantity-row { display: flex; gap: 4px; margin-bottom: 5px; margin-right: 0; }.price-value { font-size: 21px; }.total-amount { font-size: 30px; }.total-row .amount-label { font-size: 17px; }.submit-section { align-items: stretch; flex-direction: column; }.submit-section :deep(.ant-btn) { width: 100%; }.payment-hint { margin: 0; } }
@media(prefers-reduced-motion:reduce) { .address-item { transition: none; } }
</style>
