package org.example.springboot.enums;

/**
 * 支付方式枚举
 * @author system
 */
public enum PayType {
    
    /**
     * 支付宝
     */
    ALIPAY("ALI", "支付宝"),
    
    /**
     * 微信支付
     */
    WECHAT("WECHAT", "微信支付"),

    /**
     * 个人微信静态收款码，订单需管理员人工核验到账
     */
    WECHAT_QR("WECHAT_QR", "微信收款码（待人工核验）"),

    /**
     * 本地教学演示，不产生真实扣款
     */
    DEMO("DEMO", "演示支付（不扣款）"),
    
    /**
     * 其他
     */
    OTHER("OTHER", "其他");

    private final String code;
    private final String description;

    PayType(String code, String description) {
        this.code = code;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getDescription() {
        return description;
    }

    /**
     * 根据code获取枚举
     */
    public static PayType fromCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }
        for (PayType type : PayType.values()) {
            if (type.code.equals(code)) {
                return type;
            }
        }
        return null;
    }

    /**
     * 获取描述
     */
    public static String getDescription(String code) {
        PayType type = fromCode(code);
        return type != null ? type.description : "未知";
    }

    /** Describe QR payments accurately after the administrator's reconciliation. */
    public static String getDescription(String code, Integer orderStatus) {
        if (WECHAT_QR.code.equals(code)
                && orderStatus != null
                && (OrderStatus.PAID.getCode().equals(orderStatus)
                || OrderStatus.SHIPPED.getCode().equals(orderStatus)
                || OrderStatus.COMPLETED.getCode().equals(orderStatus))) {
            return "微信收款码（人工核验已完成）";
        }
        return getDescription(code);
    }
}

