import request from "@/utils/request";

/**
 * @description 创建订单
 * @param {object} params - 订单创建参数
 * @param {string} params.productId - 商品ID
 * @param {number} params.quantity - 购买数量
 * @param {number} params.addressId - 收货地址ID
 * @param {string} [params.remark] - 订单备注
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function createOrder(params, callbacks = {}) {
  return request.post('/shop/order', params, callbacks);
}

/**
 * @description 获取订单详情
 * @param {number} orderId - 订单ID
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function getOrderDetail(orderId, callbacks = {}) {
  return request.get(`/shop/order/${orderId}`, null, callbacks);
}

/**
 * @description 分页查询用户订单列表
 * @param {object} params - 查询参数
 * @param {number} [params.current=1] - 当前页码
 * @param {number} [params.size=10] - 每页大小
 * @param {number} [params.status] - 订单状态
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function getUserOrderPage(params, callbacks = {}) {
  return request.get('/shop/order/page', params, callbacks);
}

/**
 * @description 分页查询管理员订单列表
 * @param {object} params - 查询参数
 * @param {number} [params.current=1] - 当前页码
 * @param {number} [params.size=10] - 每页大小
 * @param {number} [params.status] - 订单状态
 * @param {string} [params.orderNo] - 订单号
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function getAdminOrderPage(params, callbacks = {}) {
  return request.get('/shop/order/admin/page', params, callbacks);
}

/**
 * @description 发起本地演示支付（不会扣款）
 * @param {number} orderId - 订单ID
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function startDemoPayment(orderId, callbacks = {}) {
  return request.post(`/shop/order/${orderId}/payment/demo`, null, callbacks);
}

/** Confirm the user's explicit demo-payment action; this does not represent real collection. */
export function confirmDemoPayment(orderId, callbacks = {}) {
  return request.post(`/shop/order/${orderId}/payment/demo/confirm`, null, callbacks);
}

/** Select the static WeChat QR code; the order remains unpaid until an administrator verifies receipt. */
export function startWechatQrPayment(orderId, callbacks = {}) {
  return request.post(`/shop/order/${orderId}/payment/wechat-qr`, null, callbacks);
}

/** Administrator-only reconciliation after checking the actual WeChat ledger. */
export function confirmWechatQrPayment(orderId, callbacks = {}) {
  return request.post(`/shop/order/${orderId}/payment/wechat-qr/confirm`, null, callbacks);
}

/** Read the server-persisted payment status; never trust a client-side payment result. */
export function getPaymentStatus(orderId, callbacks = {}) {
  return request.get(`/shop/order/${orderId}/payment/status`, null, callbacks);
}

/**
 * @description 取消订单
 * @param {number} orderId - 订单ID
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function cancelOrder(orderId, callbacks = {}) {
  return request.put(`/shop/order/${orderId}/cancel`, null, callbacks);
}

/**
 * @description 发货（管理员）
 * @param {number} orderId - 订单ID
 * @param {string} logisticsNo - 物流单号
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function shipOrder(orderId, logisticsNo, callbacks = {}) {
  return request.put(`/shop/order/${orderId}/ship?logisticsNo=${logisticsNo}`, null, callbacks);
}

/**
 * @description 确认收货
 * @param {number} orderId - 订单ID
 * @param {object} [callbacks={}] - 回调函数
 * @returns {Promise}
 */
export function confirmOrder(orderId, callbacks = {}) {
  return request.put(`/shop/order/${orderId}/confirm`, null, callbacks);
}

