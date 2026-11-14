<template>
  <div class="order-detail-wrapper">
    <div class="order-detail-container">
      <a-card v-if="orderDetail" class="order-detail-card">
      <!-- 订单头部 -->
      <div class="order-header">
        <div><span class="page-eyebrow">THE JOURNEY OF YOUR COLLECTION</span><h2>订单 · 详情</h2></div>
        <a-tag :color="getStatusColor(orderDetail.status)" style="font-size: 16px; padding: 4px 12px;">
          {{ orderDetail.statusName }}
        </a-tag>
      </div>

      <!-- 订单信息 -->
      <a-descriptions title="订单信息" bordered :column="{ xs: 1, sm: 2 }">
        <a-descriptions-item label="订单号">{{ orderDetail.orderNo }}</a-descriptions-item>
        <a-descriptions-item label="订单状态">{{ orderDetail.statusName }}</a-descriptions-item>
        <a-descriptions-item label="下单时间">{{ formatDate(orderDetail.createTime) }}</a-descriptions-item>
        <a-descriptions-item label="支付时间">
          {{ orderDetail.payTime ? formatDate(orderDetail.payTime) : '未支付' }}
        </a-descriptions-item>
        <a-descriptions-item label="支付方式">
          {{ orderDetail.payTypeName || '未支付' }}
        </a-descriptions-item>
        <a-descriptions-item label="物流单号">
          {{ orderDetail.logisticsNo || '暂无' }}
        </a-descriptions-item>
      </a-descriptions>

      <!-- 收货地址 -->
      <a-descriptions title="收货地址" bordered :column="1" style="margin-top: 24px;" v-if="orderDetail.address">
        <a-descriptions-item label="收货人">{{ orderDetail.address.receiver }}</a-descriptions-item>
        <a-descriptions-item label="联系电话">{{ orderDetail.address.phone }}</a-descriptions-item>
        <a-descriptions-item label="收货地址">{{ orderDetail.address.fullAddress }}</a-descriptions-item>
      </a-descriptions>

      <!-- 商品明细 -->
      <div class="order-items" style="margin-top: 24px;">
        <h3>商品明细</h3>
        <a-table
          :dataSource="orderDetail.items"
          :columns="itemColumns"
          :pagination="false"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'title'">
              <div>
                <div>{{ record.title }}</div>
                <div style="color: #999; font-size: 12px;" v-if="record.skuTitle">
                  {{ record.skuTitle }}
                </div>
              </div>
            </template>
            <template v-else-if="column.key === 'price'">
              <span style="color: #ff4d4f;">¥{{ record.price }}</span>
            </template>
            <template v-else-if="column.key === 'subtotal'">
              <span style="color: #ff4d4f; font-weight: bold;">¥{{ record.subtotal }}</span>
            </template>
          </template>
        </a-table>
      </div>

      <!-- 金额统计 -->
      <div class="order-summary">
        <div class="summary-item">
          <span class="label">商品总额:</span>
          <span class="value">¥{{ orderDetail.totalAmount }}</span>
        </div>
        <div class="summary-item total">
          <span class="label">实付金额:</span>
          <span class="value">¥{{ orderDetail.payAmount }}</span>
        </div>
      </div>

      <section
        v-if="orderDetail.status === 0 && (wechatQrVisible || orderDetail.payType === 'WECHAT_QR')"
        class="wechat-qr-panel"
        aria-labelledby="wechat-qr-title"
      >
        <div class="wechat-qr-copy">
          <span class="qr-eyebrow">WECHAT · MANUAL RECONCILIATION</span>
          <h3 id="wechat-qr-title">微信扫码收款</h3>
          <p>请使用微信扫描收款码，并手动输入本订单的准确金额。付款后订单会保持“待支付”，管理员核对微信账单到账后才会确认。</p>
          <div class="qr-order-amount">
            <span>本单应付</span>
            <strong>¥{{ orderDetail.payAmount }}</strong>
          </div>
          <p class="qr-warning">此为个人静态收款码，不会自动关联订单，也无法自动回传支付结果。请勿向他人转发订单页或收款码。</p>
          <a-button type="primary" @click="wechatQrVisible = true">
            放大收款码
          </a-button>
        </div>
        <figure class="wechat-qr-image-wrap">
          <img
            class="wechat-qr-image"
            :src="paymentQrPath"
            alt="个人微信收款二维码"
          >
          <figcaption>请在微信收款页面核对收款方与金额</figcaption>
        </figure>
      </section>

      <!-- 订单备注 -->
      <div class="order-remark" v-if="orderDetail.remark">
        <h3>订单备注</h3>
        <p>{{ orderDetail.remark }}</p>
      </div>

      <!-- 操作按钮 -->
      <div class="order-actions">
        <a-button @click="goBack">返回</a-button>
        <a-button
          v-if="orderDetail.status === 0 && (!orderDetail.payType || orderDetail.payType === 'WECHAT_QR')"
          type="primary"
          @click="handleWechatQrPayment"
          style="margin-left: auto;"
          :loading="paymentLoading"
        >
          <i class="fab fa-weixin"></i>
          使用微信收款码
        </a-button>
        <a-button
          v-if="orderDetail.status === 0 || orderDetail.status === 1"
          danger
          @click="handleCancelOrder"
        >
          取消订单
        </a-button>
        <a-button
          v-if="orderDetail.status === 2"
          type="primary"
          @click="handleConfirmOrder"
        >
          确认收货
        </a-button>
      </div>
    </a-card>

    <a-spin v-else class="loading-spinner" size="large" />
    </div>
  </div>

  <a-modal
    v-model:open="wechatQrVisible"
    title="微信支付"
    :footer="null"
    width="460px"
    centered
  >
    <div class="wechat-qr-modal">
      <p class="wechat-qr-modal-title">请使用微信扫描下方收款码</p>
      <img
        class="wechat-qr-modal-image"
        :src="paymentQrPath"
        alt="微信收款二维码"
      >
      <p class="wechat-qr-modal-amount">应付金额：<strong>¥{{ orderDetail?.payAmount }}</strong></p>
      <p class="wechat-qr-modal-tip">请按订单金额转账。个人收款码不会自动回传结果，管理员核对到账后会更新订单。</p>
    </div>
  </a-modal>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { Modal } from 'ant-design-vue';
import {
  getOrderDetail,
  cancelOrder,
  confirmOrder,
  startWechatQrPayment
} from '@/api/OrderApi';
import { withDisplayYear } from '@/utils/dateUtils';

const router = useRouter();
const route = useRoute();
const paymentQrPath = `${import.meta.env.BASE_URL}payment/wechat-personal-qr.jpg`;

// 数据
const orderDetail = ref(null);
const paymentLoading = ref(false);
const wechatQrVisible = ref(false);

// 表格列定义
const itemColumns = [
  {
    title: '商品名称',
    key: 'title',
    dataIndex: 'title'
  },
  {
    title: '单价',
    key: 'price',
    dataIndex: 'price',
    width: 120
  },
  {
    title: '数量',
    key: 'quantity',
    dataIndex: 'quantity',
    width: 100
  },
  {
    title: '小计',
    key: 'subtotal',
    dataIndex: 'subtotal',
    width: 120
  }
];

// 加载订单详情
const loadOrderDetail = () => {
  const orderId = route.params.id;
  return getOrderDetail(orderId, {
    onSuccess: (res) => {
      orderDetail.value = res;
    },
    onError: () => {
      router.push('/orders');
    }
  });
};

const handleWechatQrPayment = async () => {
  if (!orderDetail.value || paymentLoading.value) return;
  wechatQrVisible.value = true;
  orderDetail.value.payType = 'WECHAT_QR';
  orderDetail.value.payTypeName = '微信收款码（待人工核验）';
  paymentLoading.value = true;
  try {
    const status = await startWechatQrPayment(orderDetail.value.id, { showDefaultMsg: false });
    Object.assign(orderDetail.value, status);
  } catch (error) {
    // The QR remains usable when an older backend has not deployed the optional selection endpoint.
    console.warn('微信收款码订单记录接口暂不可用，继续展示二维码：', error);
  } finally {
    paymentLoading.value = false;
  }
};

// 取消订单
const handleCancelOrder = () => {
  Modal.confirm({
    title: '确认取消',
    content: '确定要取消该订单吗？',
    onOk: () => {
      cancelOrder(orderDetail.value.id, {
        successMsg: '订单已取消',
        onSuccess: () => {
          loadOrderDetail();
        }
      });
    }
  });
};

// 确认收货
const handleConfirmOrder = () => {
  Modal.confirm({
    title: '确认收货',
    content: '确定已收到商品吗？',
    onOk: () => {
      confirmOrder(orderDetail.value.id, {
        successMsg: '已确认收货',
        onSuccess: () => {
          loadOrderDetail();
        }
      });
    }
  });
};

// 返回
const goBack = () => {
  router.back();
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
  loadOrderDetail();
});

watch(() => route.params.id, () => loadOrderDetail());
</script>

<style scoped>
.order-detail-wrapper { padding: 42px 0 70px; min-height: 65vh; color: #46523e; }.order-detail-container { width: min(1080px,calc(100% - 80px)); margin: auto; }
.order-detail-card { border-color: #d8c9ac; background: #fffdf6e8; border-radius: 1px; }.order-detail-card :deep(.ant-card-body) { padding: 35px 38px; }
.order-header { display: flex; justify-content: space-between; align-items: center; gap: 20px; padding-bottom: 25px; margin-bottom: 28px; border-bottom: 1px solid #cbb997; }.page-eyebrow { font-size: 9px; letter-spacing: .16em; color: #a18a65; }.order-header h2 { font: 32px/1.6 'Songti SC',serif; letter-spacing: .15em; color: #3e523c; margin: 10px 0 0; }.order-header :deep(.ant-tag) { font-size: 12px!important; padding: 5px 15px!important; }
.order-header>div,.order-items { min-width: 0; }.order-header>div { overflow-wrap: anywhere; }.order-header :deep(.ant-tag) { flex-shrink: 0; }
.order-detail-card :deep(.ant-descriptions-title),.order-items h3,.order-remark h3 { font: 18px 'Songti SC',serif; letter-spacing: .09em; color: #586148; }.order-detail-card :deep(.ant-descriptions-header) { margin-bottom: 15px; }.order-detail-card :deep(.ant-descriptions-view) { border-radius: 0; border-color: #d9cdb5; }.order-detail-card :deep(.ant-descriptions-bordered .ant-descriptions-item-label) { background: #eee6d6; font-size: 11px; color: #8c7c60; width: 120px; }.order-detail-card :deep(.ant-descriptions-bordered .ant-descriptions-item-content) { background: #fffdf7; font-size: 12px; color: #667057; overflow-wrap: anywhere; }.order-detail-card :deep(.ant-descriptions-bordered .ant-descriptions-row) { border-color: #e3d7c0; }
.order-items { overflow-x: auto; }.order-items h3 { margin-bottom: 17px; }.order-items :deep(.ant-table) { background: #fffdf7; font-size: 12px; border-radius: 0; }.order-items :deep(.ant-table-thead>tr>th) { background: #eee6d6; color: #8b7d61; font-size: 11px; font-weight: 400; border-bottom-color: #d4c29f; }.order-items :deep(.ant-table-tbody>tr>td) { border-color: #e5d8c0; color: #657054; padding-block: 20px; }.order-items :deep(.ant-table-tbody>tr>td span[style*='color']) { color: #a23a2c!important; }.order-items :deep(.ant-table-container) { border: 1px solid #dfd2b7; border-radius: 0; }
.order-summary { margin-top: 24px; padding: 23px 26px; background: #eee5d3; }.summary-item { display: flex; align-items: center; justify-content: flex-end; gap: 50px; color: #8c7c61; font-size: 11px; }.summary-item .value { min-width: 130px; text-align: right; color: #71815d; font: 22px Georgia,serif; }.summary-item.total { border-top: 1px solid #d1bf9a; padding-top: 20px; margin-top: 20px; }.summary-item.total .label { font: 18px 'Songti SC',serif; letter-spacing: .1em; color: #5f684c; }.summary-item.total .value { color: #a23a2c; font-size: 33px; }
.wechat-qr-panel { display: grid; grid-template-columns: minmax(0, 1fr) 280px; gap: 32px; align-items: center; margin-top: 22px; padding: 28px; border: 1px solid #c9dfcc; background: linear-gradient(135deg,#f1f8ef,#fffdf6 68%); }.qr-eyebrow { color: #5f9670; font-size: 9px; letter-spacing: .16em; }.wechat-qr-copy h3 { margin: 9px 0 12px; color: #3e523c; font: 25px 'Songti SC',serif; letter-spacing: .1em; }.wechat-qr-copy p { color: #667057; font-size: 12px; line-height: 1.9; }.qr-order-amount { display: flex; align-items: center; gap: 18px; margin: 18px 0; color: #8c7c61; }.qr-order-amount strong { color: #a23a2c; font: 32px Georgia,serif; }.wechat-qr-copy .qr-warning { color: #958569; font-size: 11px; }.wechat-qr-image-wrap { width: 100%; margin: 0; padding: 10px; border: 1px solid #d8e5d7; background: white; text-align: center; }.wechat-qr-image { display: block; width: 100%; height: auto; }.wechat-qr-image-wrap figcaption { padding: 8px 0 2px; color: #829077; font-size: 10px; }
.wechat-qr-modal { padding: 4px 0 18px; text-align: center; }.wechat-qr-modal-title { color: #3e523c; font: 18px 'Songti SC',serif; letter-spacing: .08em; }.wechat-qr-modal-image { display: block; width: min(100%, 360px); max-height: 520px; margin: 18px auto; object-fit: contain; }.wechat-qr-modal-amount { color: #8c7c61; font-size: 14px; }.wechat-qr-modal-amount strong { color: #a23a2c; font: 26px Georgia,serif; }.wechat-qr-modal-tip { margin: 12px auto 0; max-width: 340px; color: #8d866f; font-size: 12px; line-height: 1.8; }
.order-remark { margin-top: 25px; padding: 20px 24px; border-left: 2px solid #c1a275; background: #f4efe2; }.order-remark h3 { margin: 0 0 12px; font-size: 16px; }.order-remark p { margin: 0; color: #8e856f; font-size: 12px; line-height: 2; overflow-wrap: anywhere; }
.order-actions { display: flex; flex-wrap: wrap; gap: 12px; padding-top: 30px; margin-top: 30px; border-top: 1px solid #d5c8ad; }.order-actions :deep(.ant-btn) { height: 38px; min-width: 106px; font-size: 12px; }.order-actions i { margin-right: 7px; }.order-actions :deep(.ant-btn-default) { background: #fffaf0; border-color: #cabb9f; color: #8b7b5e; }.order-actions :deep(.ant-btn-dangerous) { color: #a74637; border-color: #d9b9a6; }.loading-spinner { display: flex; justify-content: center; padding: 100px 0; }
@media(max-width:720px) { .order-detail-wrapper { padding: 24px 0 40px; }.order-detail-container { width: calc(100% - 32px); }.order-detail-card :deep(.ant-card-body) { padding: 23px 17px; }.order-header { gap: 12px; padding-bottom: 20px; }.page-eyebrow { font-size: 7px; letter-spacing: .05em; }.order-header h2 { font-size: 27px; }.order-header :deep(.ant-tag) { font-size: 10px!important; padding: 4px 9px!important; margin-right: 0; }.order-detail-card :deep(.ant-descriptions-bordered .ant-descriptions-item-label) { width: 86px; font-size: 10px; padding: 13px 10px; }.order-detail-card :deep(.ant-descriptions-bordered .ant-descriptions-item-content) { padding: 13px 11px; font-size: 11px; }.order-detail-card :deep(.ant-descriptions-title),.order-items h3 { font-size: 17px; }.order-items :deep(.ant-table) { min-width: 560px; font-size: 11px; }.order-summary { padding: 21px 17px; }.summary-item { gap: 25px; }.summary-item .value { min-width: 105px; font-size: 20px; }.summary-item.total .value { font-size: 28px; }.summary-item.total .label { font-size: 16px; }.wechat-qr-panel { grid-template-columns: 1fr; gap: 20px; padding: 18px; }.wechat-qr-image-wrap { max-width: 280px; justify-self: center; }.order-actions { gap: 8px; padding-top: 22px; margin-top: 23px; }.order-actions :deep(.ant-btn) { min-width: 85px; height: 35px; font-size: 11px; } }
</style>
