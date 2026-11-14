package org.example.springboot.service;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.example.springboot.dto.command.OrderCreateCommandDTO;
import org.example.springboot.dto.response.OrderListResponseDTO;
import org.example.springboot.dto.response.OrderResponseDTO;
import org.example.springboot.dto.response.PaymentStatusResponseDTO;
import org.example.springboot.entity.ShopOrder;
import org.example.springboot.entity.ShopOrderItem;
import org.example.springboot.entity.ShopProduct;
import org.example.springboot.entity.UserAddress;
import org.example.springboot.enums.OrderStatus;
import org.example.springboot.enums.PayType;
import org.example.springboot.exception.BusinessException;
import org.example.springboot.mapper.ShopOrderItemMapper;
import org.example.springboot.mapper.ShopOrderMapper;
import org.example.springboot.mapper.ShopProductMapper;
import org.example.springboot.service.convert.OrderConvert;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Value;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 订单服务
 * @author system
 */
@Slf4j
@Service
public class OrderService {

    @Value("${heritage.payment.demo-enabled:false}")
    private boolean demoPaymentEnabled;

    @Resource
    private ShopOrderMapper shopOrderMapper;

    @Resource
    private ShopOrderItemMapper shopOrderItemMapper;

    @Resource
    private ShopProductMapper shopProductMapper;

    @Resource
    private UserAddressService userAddressService;

    /**
     * 创建订单
     */
    @Transactional(rollbackFor = Exception.class)
    public OrderResponseDTO createOrder(OrderCreateCommandDTO dto, Long userId) {
        log.info("创建订单，用户ID: {}, 商品ID: {}, 数量: {}", userId, dto.getProductId(), dto.getQuantity());
        
        // 1. 验证商品
        ShopProduct product = shopProductMapper.selectById(dto.getProductId());
        if (product == null) {
            throw new BusinessException("商品不存在");
        }
        if (!product.canPurchase()) {
            throw new BusinessException("商品已下架或库存不足");
        }
        if (!product.checkStock(dto.getQuantity())) {
            throw new BusinessException("商品库存不足");
        }
        
        // 2. 验证收货地址
        UserAddress address = userAddressService.getAddressEntityById(dto.getAddressId());
        if (!address.getUserId().equals(userId)) {
            throw new BusinessException("无权使用该收货地址");
        }
        
        // 3. 计算订单金额
        BigDecimal totalAmount = product.getPrice().multiply(BigDecimal.valueOf(dto.getQuantity()));
        BigDecimal payAmount = totalAmount; // 暂不考虑优惠
        
        // 4. 生成订单号
        String orderNo = generateOrderNo(userId);
        
        // 5. 创建订单主表
        ShopOrder order = ShopOrder.builder()
                .orderNo(orderNo)
                .userId(userId)
                .totalAmount(totalAmount)
                .payAmount(payAmount)
                .status(OrderStatus.PENDING.getCode())
                .receiverAddressId(address.getId())
                .remark(dto.getRemark())
                .build();
        shopOrderMapper.insert(order);
        
        // 6. 创建订单明细
        ShopOrderItem orderItem = ShopOrderItem.builder()
                .orderId(order.getId())
                .productId(product.getId())
                .skuId(product.getId()) // 暂无SKU，使用商品ID
                .title(product.getTitle())
                .skuTitle(product.getSubtitle())
                .price(product.getPrice())
                .quantity(dto.getQuantity())
                .subtotal(totalAmount)
                .build();
        shopOrderItemMapper.insert(orderItem);
        
        // 7. 扣减库存
        boolean stockReduced = product.reduceStock(dto.getQuantity());
        if (!stockReduced) {
            throw new BusinessException("库存扣减失败");
        }
        shopProductMapper.updateById(product);
        
        log.info("订单创建成功，订单号: {}", orderNo);
        
        // 8. 返回订单详情
        List<ShopOrderItem> items = new ArrayList<>();
        items.add(orderItem);
        OrderResponseDTO response = OrderConvert.toResponseDTO(order, address, items);
        response.setDemoPaymentEnabled(demoPaymentEnabled);
        response.setDemoPaymentReady(demoPaymentEnabled
                && OrderStatus.PENDING.getCode().equals(order.getStatus())
                && PayType.DEMO.getCode().equals(order.getPayType()));
        return response;
    }

    /**
     * 获取订单详情
     */
    public OrderResponseDTO getOrderDetail(Long orderId, Long userId, boolean isAdmin) {
        log.info("获取订单详情，订单ID: {}, 用户ID: {}, 是否管理员: {}", orderId, userId, isAdmin);
        
        // 查询订单
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        
        // 权限校验（管理员可以查看所有订单）
        if (!isAdmin && !order.getUserId().equals(userId)) {
            throw new BusinessException("无权查看该订单");
        }
        
        // 查询订单明细
        LambdaQueryWrapper<ShopOrderItem> itemWrapper = new LambdaQueryWrapper<>();
        itemWrapper.eq(ShopOrderItem::getOrderId, orderId);
        List<ShopOrderItem> items = shopOrderItemMapper.selectList(itemWrapper);
        
        // 查询收货地址
        UserAddress address = null;
        if (order.getReceiverAddressId() != null) {
            address = userAddressService.getAddressEntityById(order.getReceiverAddressId());
        }
        
        OrderResponseDTO response = OrderConvert.toResponseDTO(order, address, items);
        response.setDemoPaymentEnabled(demoPaymentEnabled);
        response.setDemoPaymentReady(demoPaymentEnabled
                && OrderStatus.PENDING.getCode().equals(order.getStatus())
                && PayType.DEMO.getCode().equals(order.getPayType()));
        return response;
    }

    /**
     * 分页查询订单列表（用户）
     */
    public Page<OrderListResponseDTO> getUserOrderPage(Long current, Long size, Integer status, Long userId) {
        log.info("分页查询用户订单，用户ID: {}, 页码: {}, 大小: {}, 状态: {}", userId, current, size, status);
        
        // 构建分页对象
        Page<ShopOrder> page = new Page<>(current, size);
        
        // 构建查询条件
        LambdaQueryWrapper<ShopOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ShopOrder::getUserId, userId);
        if (status != null) {
            wrapper.eq(ShopOrder::getStatus, status);
        }
        wrapper.orderByDesc(ShopOrder::getCreateTime);
        
        // 查询订单
        Page<ShopOrder> orderPage = shopOrderMapper.selectPage(page, wrapper);
        
        // 查询所有订单的明细
        List<Long> orderIds = orderPage.getRecords().stream()
                .map(ShopOrder::getId)
                .collect(Collectors.toList());
        
        Map<Long, List<ShopOrderItem>> itemsMap = getOrderItemsMap(orderIds);
        
        // 转换为DTO
        Page<OrderListResponseDTO> resultPage = new Page<>(orderPage.getCurrent(), orderPage.getSize(), orderPage.getTotal());
        List<OrderListResponseDTO> records = orderPage.getRecords().stream()
                .map(order -> OrderConvert.toListResponseDTO(order, itemsMap.get(order.getId())))
                .collect(Collectors.toList());
        resultPage.setRecords(records);
        
        return resultPage;
    }

    /**
     * 分页查询订单列表（管理员）
     */
    public Page<OrderListResponseDTO> getAdminOrderPage(Long current, Long size, Integer status, String orderNo) {
        log.info("分页查询管理员订单，页码: {}, 大小: {}, 状态: {}, 订单号: {}", current, size, status, orderNo);
        
        // 构建分页对象
        Page<ShopOrder> page = new Page<>(current, size);
        
        // 构建查询条件
        LambdaQueryWrapper<ShopOrder> wrapper = new LambdaQueryWrapper<>();
        if (status != null) {
            wrapper.eq(ShopOrder::getStatus, status);
        }
        if (orderNo != null && !orderNo.trim().isEmpty()) {
            wrapper.like(ShopOrder::getOrderNo, orderNo);
        }
        wrapper.orderByDesc(ShopOrder::getCreateTime);
        
        // 查询订单
        Page<ShopOrder> orderPage = shopOrderMapper.selectPage(page, wrapper);
        
        // 查询所有订单的明细
        List<Long> orderIds = orderPage.getRecords().stream()
                .map(ShopOrder::getId)
                .collect(Collectors.toList());
        
        Map<Long, List<ShopOrderItem>> itemsMap = getOrderItemsMap(orderIds);
        
        // 转换为DTO
        Page<OrderListResponseDTO> resultPage = new Page<>(orderPage.getCurrent(), orderPage.getSize(), orderPage.getTotal());
        List<OrderListResponseDTO> records = orderPage.getRecords().stream()
                .map(order -> OrderConvert.toListResponseDTO(order, itemsMap.get(order.getId())))
                .collect(Collectors.toList());
        resultPage.setRecords(records);
        
        return resultPage;
    }

    /**
     * Start the explicitly labeled local demo flow. This does not mark the order as paid.
     */
    @Transactional(rollbackFor = Exception.class)
    public PaymentStatusResponseDTO startDemoPayment(Long orderId, Long userId) {
        ensureDemoPaymentEnabled();
        ShopOrder order = getOwnedOrder(orderId, userId);
        if (!OrderStatus.PENDING.getCode().equals(order.getStatus())) {
            throw new BusinessException("只有待支付订单可以发起演示支付");
        }
        if (order.getPayType() != null && !PayType.DEMO.getCode().equals(order.getPayType())) {
            throw new BusinessException("该订单已选择其他支付方式，请联系管理员处理");
        }

        LambdaUpdateWrapper<ShopOrder> update = new LambdaUpdateWrapper<ShopOrder>()
                .eq(ShopOrder::getId, orderId)
                .eq(ShopOrder::getUserId, userId)
                .eq(ShopOrder::getStatus, OrderStatus.PENDING.getCode())
                .and(wrapper -> wrapper.isNull(ShopOrder::getPayType)
                        .or().eq(ShopOrder::getPayType, PayType.DEMO.getCode()))
                .set(ShopOrder::getPayType, PayType.DEMO.getCode());
        if (shopOrderMapper.update(null, update) == 0) {
            order = getOwnedOrder(orderId, userId);
            if (!OrderStatus.PENDING.getCode().equals(order.getStatus())
                    || !PayType.DEMO.getCode().equals(order.getPayType())) {
                throw new BusinessException("无法发起演示支付，请刷新订单状态");
            }
        } else {
            order.setPayType(PayType.DEMO.getCode());
        }
        log.info("订单进入本地演示支付，订单号: {}；不会产生真实扣款", order.getOrderNo());
        return toPaymentStatus(order);
    }

    /** Select the static WeChat collection code; payment remains pending for manual verification. */
    @Transactional(rollbackFor = Exception.class)
    public PaymentStatusResponseDTO startWechatQrPayment(Long orderId, Long userId) {
        ShopOrder order = getOwnedOrder(orderId, userId);
        if (!OrderStatus.PENDING.getCode().equals(order.getStatus())) {
            throw new BusinessException("只有待支付订单可以选择微信收款码");
        }
        if (order.getPayType() != null
                && !PayType.WECHAT_QR.getCode().equals(order.getPayType())) {
            throw new BusinessException("该订单已选择其他支付方式，请刷新订单后重试");
        }

        LambdaUpdateWrapper<ShopOrder> update = new LambdaUpdateWrapper<ShopOrder>()
                .eq(ShopOrder::getId, orderId)
                .eq(ShopOrder::getUserId, userId)
                .eq(ShopOrder::getStatus, OrderStatus.PENDING.getCode())
                .and(wrapper -> wrapper.isNull(ShopOrder::getPayType)
                        .or().eq(ShopOrder::getPayType, PayType.WECHAT_QR.getCode()))
                .set(ShopOrder::getPayType, PayType.WECHAT_QR.getCode());
        if (shopOrderMapper.update(null, update) == 0) {
            order = getOwnedOrder(orderId, userId);
            if (!OrderStatus.PENDING.getCode().equals(order.getStatus())
                    || !PayType.WECHAT_QR.getCode().equals(order.getPayType())) {
                throw new BusinessException("无法选择微信收款码，请刷新订单状态");
            }
        } else {
            order.setPayType(PayType.WECHAT_QR.getCode());
        }

        log.info("订单选择个人微信收款码，等待人工核验，订单号: {}, 金额: {}",
                order.getOrderNo(), order.getPayAmount());
        return toPaymentStatus(order);
    }

    /** Mark a QR order paid only after an administrator has checked the received WeChat funds. */
    @Transactional(rollbackFor = Exception.class)
    public PaymentStatusResponseDTO confirmWechatQrPayment(Long orderId, Long adminId) {
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (!OrderStatus.PENDING.getCode().equals(order.getStatus())
                || !PayType.WECHAT_QR.getCode().equals(order.getPayType())) {
            throw new BusinessException("仅待人工核验的微信收款码订单可以确认到账");
        }

        LocalDateTime paidAt = LocalDateTime.now();
        LambdaUpdateWrapper<ShopOrder> update = new LambdaUpdateWrapper<ShopOrder>()
                .eq(ShopOrder::getId, orderId)
                .eq(ShopOrder::getStatus, OrderStatus.PENDING.getCode())
                .eq(ShopOrder::getPayType, PayType.WECHAT_QR.getCode())
                .set(ShopOrder::getStatus, OrderStatus.PAID.getCode())
                .set(ShopOrder::getPayTime, paidAt);
        if (shopOrderMapper.update(null, update) == 0) {
            order = shopOrderMapper.selectById(orderId);
            if (order == null || !OrderStatus.PAID.getCode().equals(order.getStatus())
                    || !PayType.WECHAT_QR.getCode().equals(order.getPayType())) {
                throw new BusinessException("订单状态已变化，请刷新后重试");
            }
            return toPaymentStatus(order);
        }

        order.setStatus(OrderStatus.PAID.getCode());
        order.setPayTime(paidAt);
        log.warn("管理员人工确认微信收款到账，订单号: {}, 金额: {}, 管理员ID: {}, 时间: {}",
                order.getOrderNo(), order.getPayAmount(), adminId, paidAt);
        return toPaymentStatus(order);
    }

    /**
     * Simulate a confirmed payment only after an explicit user action in demo mode.
     */
    @Transactional(rollbackFor = Exception.class)
    public PaymentStatusResponseDTO confirmDemoPayment(Long orderId, Long userId) {
        ensureDemoPaymentEnabled();
        ShopOrder order = getOwnedOrder(orderId, userId);
        if (OrderStatus.PAID.getCode().equals(order.getStatus())
                && PayType.DEMO.getCode().equals(order.getPayType())) {
            return toPaymentStatus(order);
        }
        if (!OrderStatus.PENDING.getCode().equals(order.getStatus())
                || !PayType.DEMO.getCode().equals(order.getPayType())) {
            throw new BusinessException("请先发起演示支付，且订单须处于待支付状态");
        }

        LocalDateTime paidAt = LocalDateTime.now();
        LambdaUpdateWrapper<ShopOrder> update = new LambdaUpdateWrapper<ShopOrder>()
                .eq(ShopOrder::getId, orderId)
                .eq(ShopOrder::getUserId, userId)
                .eq(ShopOrder::getStatus, OrderStatus.PENDING.getCode())
                .eq(ShopOrder::getPayType, PayType.DEMO.getCode())
                .set(ShopOrder::getStatus, OrderStatus.PAID.getCode())
                .set(ShopOrder::getPayTime, paidAt);
        if (shopOrderMapper.update(null, update) == 0) {
            order = getOwnedOrder(orderId, userId);
            if (!OrderStatus.PAID.getCode().equals(order.getStatus())
                    || !PayType.DEMO.getCode().equals(order.getPayType())) {
                throw new BusinessException("订单状态已变化，请刷新后重试");
            }
            return toPaymentStatus(order);
        }

        order.setStatus(OrderStatus.PAID.getCode());
        order.setPayTime(paidAt);
        log.info("本地演示支付已确认，订单号: {}；该记录不代表真实收款", order.getOrderNo());
        return toPaymentStatus(order);
    }

    /** Read the authoritative payment state stored for this user's order. */
    public PaymentStatusResponseDTO getPaymentStatus(Long orderId, Long userId, boolean isAdmin) {
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (!isAdmin && !Objects.equals(order.getUserId(), userId)) {
            throw new BusinessException("无权查看该订单");
        }
        return toPaymentStatus(order);
    }

    private ShopOrder getOwnedOrder(Long orderId, Long userId) {
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (userId == null || !Objects.equals(order.getUserId(), userId)) {
            throw new BusinessException("无权操作该订单");
        }
        return order;
    }

    private void ensureDemoPaymentEnabled() {
        if (!demoPaymentEnabled) {
            throw new BusinessException("演示支付未启用；当前环境未配置真实支付渠道");
        }
    }

    private PaymentStatusResponseDTO toPaymentStatus(ShopOrder order) {
        boolean demoReady = demoPaymentEnabled
                && OrderStatus.PENDING.getCode().equals(order.getStatus())
                && PayType.DEMO.getCode().equals(order.getPayType());
        String statusName = OrderStatus.getDescription(order.getStatus());
        return PaymentStatusResponseDTO.builder()
                .orderId(order.getId())
                .orderNo(order.getOrderNo())
                .status(order.getStatus())
                .statusName(statusName)
                .payType(order.getPayType())
                .payTypeName(PayType.getDescription(order.getPayType(), order.getStatus()))
                .payTime(order.getPayTime())
                .demoPaymentEnabled(demoPaymentEnabled)
                .demoPaymentReady(demoReady)
                .paymentMode(PayType.WECHAT_QR.getCode().equals(order.getPayType()) ? "MANUAL_QR" : "DEMO")
                .message(PayType.WECHAT_QR.getCode().equals(order.getPayType())
                        ? "个人微信收款码不回传支付结果，请等待管理员核对到账。"
                        : demoPaymentEnabled
                        ? "本地演示支付不会产生真实扣款。"
                        : "请选择微信收款码，按订单金额完成转账后等待管理员核验。")
                .build();
    }

    /**
     * 取消订单
     */
    @Transactional(rollbackFor = Exception.class)
    public void cancelOrder(Long orderId, Long userId, boolean isAdmin) {
        log.info("取消订单，订单ID: {}, 用户ID: {}, 是否管理员: {}", orderId, userId, isAdmin);
        
        // 查询订单
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        
        // 权限校验
        if (!isAdmin && !order.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该订单");
        }
        
        // 状态校验
        if (!order.canCancel()) {
            throw new BusinessException("订单状态不允许取消");
        }
        
        // 更新订单状态
        order.setStatus(OrderStatus.CLOSED.getCode());
        shopOrderMapper.updateById(order);
        
        // 恢复库存
        restoreOrderStock(orderId);
        
        log.info("订单取消成功，订单号: {}", order.getOrderNo());
    }

    /**
     * 发货
     */
    @Transactional(rollbackFor = Exception.class)
    public void shipOrder(Long orderId, String logisticsNo) {
        log.info("订单发货，订单ID: {}, 物流单号: {}", orderId, logisticsNo);
        
        // 查询订单
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        
        // 状态校验
        if (!order.canShip()) {
            throw new BusinessException("订单状态不允许发货");
        }
        
        // 更新订单状态
        order.setStatus(OrderStatus.SHIPPED.getCode());
        order.setLogisticsNo(logisticsNo);
        shopOrderMapper.updateById(order);
        
        log.info("订单发货成功，订单号: {}", order.getOrderNo());
    }

    /**
     * 确认收货
     */
    @Transactional(rollbackFor = Exception.class)
    public void confirmOrder(Long orderId, Long userId) {
        log.info("确认收货，订单ID: {}, 用户ID: {}", orderId, userId);
        
        // 查询订单
        ShopOrder order = shopOrderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        
        // 权限校验
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException("无权操作该订单");
        }
        
        // 状态校验
        if (!order.canConfirm()) {
            throw new BusinessException("订单状态不允许确认收货");
        }
        
        // 更新订单状态
        order.setStatus(OrderStatus.COMPLETED.getCode());
        shopOrderMapper.updateById(order);
        
        log.info("确认收货成功，订单号: {}", order.getOrderNo());
    }

    /**
     * 生成订单号
     */
    private String generateOrderNo(Long userId) {
        // 格式：时间戳(yyyyMMddHHmmss) + 用户ID后4位 + 4位随机数
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String userIdSuffix = String.format("%04d", userId % 10000);
        String randomSuffix = String.format("%04d", (int) (Math.random() * 10000));
        return timestamp + userIdSuffix + randomSuffix;
    }

    /**
     * 批量查询订单明细
     */
    private Map<Long, List<ShopOrderItem>> getOrderItemsMap(List<Long> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return Map.of();
        }
        
        LambdaQueryWrapper<ShopOrderItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(ShopOrderItem::getOrderId, orderIds);
        List<ShopOrderItem> items = shopOrderItemMapper.selectList(wrapper);
        
        return items.stream().collect(Collectors.groupingBy(ShopOrderItem::getOrderId));
    }

    /**
     * 恢复订单库存
     */
    private void restoreOrderStock(Long orderId) {
        // 查询订单明细
        LambdaQueryWrapper<ShopOrderItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ShopOrderItem::getOrderId, orderId);
        List<ShopOrderItem> items = shopOrderItemMapper.selectList(wrapper);
        
        // 恢复库存
        for (ShopOrderItem item : items) {
            ShopProduct product = shopProductMapper.selectById(item.getProductId());
            if (product != null) {
                product.addStock(item.getQuantity());
                shopProductMapper.updateById(product);
            }
        }
    }
}

