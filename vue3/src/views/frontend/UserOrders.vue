<template>
  <div class="user-orders-page">
    <PortalPageHeader eyebrow="MY CULTURAL COLLECTION" title="我的 · 订单" description="在这里，查看每一件好物的旅程，管理购买与收货。" mark="订单" image="/images/hero-scene-6.jpg" />
    <!-- 内容区域 -->
    <div class="user-orders-container">
      <!-- 订单状态筛选 -->
      <div class="order-tabs">
      <a-radio-group v-model:value="currentStatus" button-style="solid" @change="handleStatusChange">
        <a-radio-button :value="null">全部订单</a-radio-button>
        <a-radio-button :value="0">待支付</a-radio-button>
        <a-radio-button :value="1">已支付</a-radio-button>
        <a-radio-button :value="2">已发货</a-radio-button>
        <a-radio-button :value="3">已完成</a-radio-button>
        <a-radio-button :value="4">已关闭</a-radio-button>
      </a-radio-group>
    </div>

    <!-- 订单列表 -->
    <div class="order-list">
      <a-card v-for="order in orderList" :key="order.id" class="order-card">
        <div class="order-header">
          <span class="order-no">订单号: {{ order.orderNo }}</span>
          <a-tag :color="getStatusColor(order.status)">{{ order.statusName }}</a-tag>
        </div>
        
        <div class="order-content">
          <div class="order-product">
            <span class="product-title">{{ order.mainProductTitle }}</span>
            <span class="product-count">共{{ order.itemCount }}件商品</span>
          </div>
          
          <div class="order-amount">
            <span class="amount-label">实付金额:</span>
            <span class="amount-value">¥{{ order.payAmount }}</span>
          </div>
          
          <div class="order-actions">
            <a-button type="link" @click="viewOrderDetail(order.id)">查看详情</a-button>
            <a-button
              v-if="order.status === 0 || order.status === 1"
              type="link"
              danger
              @click="handleCancelOrder(order.id)"
            >
              取消订单
            </a-button>
            <a-button
              v-if="order.status === 2"
              type="primary"
              size="small"
              @click="handleConfirmOrder(order.id)"
            >
              确认收货
            </a-button>
          </div>
        </div>
        
        <div class="order-footer">
          <span class="order-time">下单时间: {{ formatDate(order.createTime) }}</span>
        </div>
      </a-card>
      
      <a-empty v-if="orderList.length === 0" description="暂无订单" />
    </div>

      <!-- 分页 -->
      <div class="pagination" v-if="total > 0">
        <a-pagination
          v-model:current="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          show-size-changer
          @change="loadOrderList"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { Modal } from 'ant-design-vue';
import { getUserOrderPage, cancelOrder, confirmOrder } from '@/api/OrderApi';
import PortalPageHeader from '@/components/frontend/PortalPageHeader.vue';
import { withDisplayYear } from '@/utils/dateUtils';

const router = useRouter();

// 数据
const orderList = ref([]);
const currentStatus = ref(null);
const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(0);

// 加载订单列表
const loadOrderList = () => {
  const params = {
    current: currentPage.value,
    size: pageSize.value
  };
  
  if (currentStatus.value !== null) {
    params.status = currentStatus.value;
  }
  
  getUserOrderPage(params, {
    onSuccess: (res) => {
      orderList.value = res.records || [];
      total.value = res.total || 0;
    }
  });
};

// 状态改变
const handleStatusChange = () => {
  currentPage.value = 1;
  loadOrderList();
};

// 查看详情
const viewOrderDetail = (orderId) => {
  router.push(`/orders/${orderId}`);
};

// 取消订单
const handleCancelOrder = (orderId) => {
  Modal.confirm({
    title: '确认取消',
    content: '确定要取消该订单吗？',
    onOk: () => {
      cancelOrder(orderId, {
        successMsg: '订单已取消',
        onSuccess: () => {
          loadOrderList();
        }
      });
    }
  });
};

// 确认收货
const handleConfirmOrder = (orderId) => {
  Modal.confirm({
    title: '确认收货',
    content: '确定已收到商品吗？',
    onOk: () => {
      confirmOrder(orderId, {
        successMsg: '已确认收货',
        onSuccess: () => {
          loadOrderList();
        }
      });
    }
  });
};

// 获取状态颜色
const getStatusColor = (status) => {
  const colorMap = {
    0: 'orange',
    1: 'blue',
    2: 'cyan',
    3: 'green',
    4: 'default'
  };
  return colorMap[status] || 'default';
};

// 格式化日期
const formatDate = (dateStr) => {
  if (!dateStr) return '';
  const date = withDisplayYear(dateStr);
  if (!date) return '';
  return date.toLocaleString('zh-CN');
};

// 页面加载
onMounted(() => {
  loadOrderList();
});
</script>

<style scoped>
.user-orders-page { min-height: 70vh; color: #46523d; padding-bottom: 70px; }.user-orders-container { width: min(1180px,calc(100% - 96px)); margin: auto; }
.order-tabs { padding: 28px 0; border-bottom: 1px solid #cfbea0; margin-bottom: 30px; }.order-tabs :deep(.ant-radio-group) { display: flex; flex-wrap: wrap; gap: 6px; }.order-tabs :deep(.ant-radio-button-wrapper) { height: 37px; line-height: 35px; padding-inline: 23px; border: 1px solid transparent; background: transparent; color: #8e8067; font-size: 12px; }.order-tabs :deep(.ant-radio-button-wrapper:before) { display: none; }.order-tabs :deep(.ant-radio-button-wrapper-checked) { background: #354b3c!important; border-color: #354b3c!important; color: #f8f0dd!important; box-shadow: none; }.order-tabs :deep(.ant-radio-button-wrapper:hover) { color: #a44231; }
.order-list { display: flex; flex-direction: column; gap: 22px; }.order-card { background: #fffcf5e8; border: 1px solid #d9cbb0; border-radius: 1px; transition: border-color .3s,box-shadow .3s; }.order-card:hover { border-color: #b89c73; box-shadow: 0 9px 25px #5f4e2c0a; }.order-card :deep(.ant-card-body) { padding: 0; }
.order-header { padding: 16px 25px; display: flex; align-items: center; justify-content: space-between; gap: 15px; background: #eee6d4a8; border-bottom: 1px solid #e5d8bf; }.order-no { color: #95836a; font-size: 10px; letter-spacing: .04em; overflow-wrap: anywhere; }.order-header :deep(.ant-tag) { font-size: 10px; padding: 1px 10px; margin-right: 0; flex-shrink: 0; }
.order-content { display: flex; align-items: center; gap: 30px; padding: 31px 25px; }.order-product { display: flex; flex-direction: column; flex: 1; gap: 10px; }.product-title { font: 21px/1.5 'Songti SC',serif; letter-spacing: .07em; color: #4d5b41; }.product-count { font-size: 10px; color: #a1957d; }.order-amount { padding: 0 30px; border-left: 1px solid #e1d5bb; border-right: 1px solid #e1d5bb; display: flex; flex-direction: column; gap: 10px; min-width: 170px; }.amount-label { font-size: 10px; color: #a08f72; }.amount-value { color: #a33e2e; font: 27px Georgia,serif; }.order-actions { display: flex; flex-wrap: wrap; align-items: center; justify-content: flex-end; gap: 8px; max-width: 255px; }.order-actions :deep(.ant-btn-link) { color: #8e7854; padding-inline: 8px; font-size: 11px; }.order-actions :deep(.ant-btn-dangerous) { color: #aa5e48; }.order-actions :deep(.ant-btn-primary) { height: 32px; padding-inline: 15px; font-size: 11px; }
.order-footer { padding: 13px 25px; border-top: 1px solid #eee5d3; }.order-time { color: #aaa087; font-size: 10px; letter-spacing: .025em; }
.order-product { min-width: 0; }.product-title { overflow-wrap: anywhere; }.order-no { min-width: 0; }
.pagination { display: flex; justify-content: center; margin-top: 40px; padding-top: 30px; border-top: 1px solid #d7c8ad; }.order-list :deep(.ant-empty) { margin: 0; padding: 80px 20px; background: #fffcf2a8; border: 1px solid #dfd1b6; }
.pagination :deep(.ant-pagination) { display: flex; flex-wrap: wrap; justify-content: center; gap: 7px 0; max-width: 100%; }
@media(max-width:900px) { .order-content { gap: 20px; }.order-amount { padding-inline: 20px; min-width: 145px; }.order-actions { max-width: 145px; }.product-title { font-size: 19px; } }
@media(max-width:650px) { .user-orders-page { padding-bottom: 40px; }.user-orders-container { width: calc(100% - 36px); }.order-tabs { padding: 20px 0; margin-bottom: 22px; }.order-tabs :deep(.ant-radio-group) { gap: 5px; }.order-tabs :deep(.ant-radio-button-wrapper) { padding-inline: 15px; font-size: 11px; height: 33px; line-height: 31px; }.order-list { gap: 18px; }.order-header { padding: 13px 15px; gap: 10px; }.order-no { font-size: 9px; }.order-header :deep(.ant-tag) { font-size: 9px; padding-inline: 7px; }.order-content { padding: 23px 16px; flex-wrap: wrap; gap: 20px 15px; }.order-product { flex-basis: calc(100% - 130px); }.product-title { font-size: 18px; }.product-count { font-size: 9px; }.order-amount { padding: 0 0 0 16px; min-width: 100px; border-right: 0; }.amount-label { font-size: 9px; }.amount-value { font-size: 24px; }.order-actions { width: 100%; max-width: none; justify-content: flex-end; padding-top: 14px; border-top: 1px solid #eee3ce; }.order-footer { padding: 12px 16px; }.order-time { font-size: 9px; }.pagination { margin-top: 26px; padding-top: 25px; overflow-x: auto; } }
@media(prefers-reduced-motion:reduce) { .order-card { transition: none; } }
</style>
