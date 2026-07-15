package com.dermathologyai.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Payment {
    private String id;
    private String invoiceId;
    private String paymentMethod;
    private BigDecimal amount;
    private String status;
    private String txnRef;
    private String orderInfo;
    private String paymentUrl;
    private String clientIp;
    private LocalDateTime expiresAt;
    
    // VNPay callback fields
    private String vnpTransactionNo;
    private String vnpBankCode;
    private String vnpBankTranNo;
    private String vnpCardType;
    private String vnpResponseCode;
    private String vnpTransactionStatus;
    private String vnpPayDate;
    
    private boolean signatureVerified;
    private String callbackPayload;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime processedAt;

    // Constructors
    public Payment() {}

    public Payment(String invoiceId, String paymentMethod, BigDecimal amount, String txnRef) {
        this.invoiceId = invoiceId;
        this.paymentMethod = paymentMethod;
        this.amount = amount;
        this.txnRef = txnRef;
        this.status = STATUS_PENDING;
        this.signatureVerified = false;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(String invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getTxnRef() {
        return txnRef;
    }

    public void setTxnRef(String txnRef) {
        this.txnRef = txnRef;
    }

    public String getOrderInfo() {
        return orderInfo;
    }

    public void setOrderInfo(String orderInfo) {
        this.orderInfo = orderInfo;
    }

    public String getPaymentUrl() {
        return paymentUrl;
    }

    public void setPaymentUrl(String paymentUrl) {
        this.paymentUrl = paymentUrl;
    }

    public String getClientIp() {
        return clientIp;
    }

    public void setClientIp(String clientIp) {
        this.clientIp = clientIp;
    }

    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public String getVnpTransactionNo() {
        return vnpTransactionNo;
    }

    public void setVnpTransactionNo(String vnpTransactionNo) {
        this.vnpTransactionNo = vnpTransactionNo;
    }

    public String getVnpBankCode() {
        return vnpBankCode;
    }

    public void setVnpBankCode(String vnpBankCode) {
        this.vnpBankCode = vnpBankCode;
    }

    public String getVnpBankTranNo() {
        return vnpBankTranNo;
    }

    public void setVnpBankTranNo(String vnpBankTranNo) {
        this.vnpBankTranNo = vnpBankTranNo;
    }

    public String getVnpCardType() {
        return vnpCardType;
    }

    public void setVnpCardType(String vnpCardType) {
        this.vnpCardType = vnpCardType;
    }

    public String getVnpResponseCode() {
        return vnpResponseCode;
    }

    public void setVnpResponseCode(String vnpResponseCode) {
        this.vnpResponseCode = vnpResponseCode;
    }

    public String getVnpTransactionStatus() {
        return vnpTransactionStatus;
    }

    public void setVnpTransactionStatus(String vnpTransactionStatus) {
        this.vnpTransactionStatus = vnpTransactionStatus;
    }

    public String getVnpPayDate() {
        return vnpPayDate;
    }

    public void setVnpPayDate(String vnpPayDate) {
        this.vnpPayDate = vnpPayDate;
    }

    public boolean isSignatureVerified() {
        return signatureVerified;
    }

    public void setSignatureVerified(boolean signatureVerified) {
        this.signatureVerified = signatureVerified;
    }

    public String getCallbackPayload() {
        return callbackPayload;
    }

    public void setCallbackPayload(String callbackPayload) {
        this.callbackPayload = callbackPayload;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public LocalDateTime getProcessedAt() {
        return processedAt;
    }

    public void setProcessedAt(LocalDateTime processedAt) {
        this.processedAt = processedAt;
    }

    // Constants for payment methods
    public static final String METHOD_CASH = "CASH";
    public static final String METHOD_VNPAY = "VNPAY";
    public static final String METHOD_BANK_TRANSFER = "BANK_TRANSFER";

    // Constants for status
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";
    public static final String STATUS_EXPIRED = "EXPIRED";
    public static final String STATUS_REFUNDED = "REFUNDED";

    // Helper methods
    public boolean isSuccess() {
        return STATUS_SUCCESS.equals(status);
    }

    public boolean isPending() {
        return STATUS_PENDING.equals(status);
    }

    public boolean isFailed() {
        return STATUS_FAILED.equals(status);
    }

    public boolean isCashPayment() {
        return METHOD_CASH.equals(paymentMethod);
    }

    public boolean isVnpayPayment() {
        return METHOD_VNPAY.equals(paymentMethod);
    }

    @Override
    public String toString() {
        return "Payment{" +
                "id='" + id + '\'' +
                ", invoiceId='" + invoiceId + '\'' +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", amount=" + amount +
                ", status='" + status + '\'' +
                ", txnRef='" + txnRef + '\'' +
                ", vnpTransactionNo='" + vnpTransactionNo + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}