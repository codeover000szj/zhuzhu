package org.example.springboot.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "订单支付状态；演示支付不产生真实扣款")
public class PaymentStatusResponseDTO {

    private Long orderId;
    private String orderNo;
    private Integer status;
    private String statusName;
    private String payType;
    private String payTypeName;
    private LocalDateTime payTime;
    private boolean demoPaymentEnabled;
    private boolean demoPaymentReady;
    private String paymentMode;
    private String message;
}
