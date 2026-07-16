package com.dermathologyai.service;

import com.dermathologyai.dao.*;
import com.dermathologyai.model.*;
import com.dermathologyai.util.RequestUtil;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public class PaymentService {
    private InvoiceDAO invoiceDAO;
    private PaymentDAO paymentDAO;
    private AppointmentDAO appointmentDAO;
    private AuditLogDAO auditLogDAO;

    public PaymentService() {
        this.invoiceDAO = new InvoiceDAO();
        this.paymentDAO = new PaymentDAO();
        this.appointmentDAO = new AppointmentDAO();
        this.auditLogDAO = new AuditLogDAO();
    }

    /**
     * Create or get existing invoice for an appointment
     */
    public Invoice createOrGetInvoice(String appointmentId, String userId, String clientIp, String userAgent) {
        // Check if invoice already exists
        Invoice existingInvoice = invoiceDAO.findByAppointmentId(appointmentId);
        if (existingInvoice != null) {
            return existingInvoice;
        }

        // Get appointment details
        Appointment appointment = appointmentDAO.findById(appointmentId);
        if (appointment == null) {
            throw new IllegalArgumentException("Lịch hẹn không tồn tại");
        }

        // Create new invoice
        Invoice invoice = new Invoice();
        invoice.setAppointmentId(appointmentId);
        invoice.setTotalAmount(new BigDecimal("250000")); // Default consultation fee
        invoice.setStatus(Invoice.STATUS_UNPAID);
        invoice.setDescription("Phí khám và tư vấn da liễu");

        String invoiceId = invoiceDAO.create(invoice);
        if (invoiceId != null) {
            invoice.setId(invoiceId);
            
            // Log audit
            auditLogDAO.createLog(userId, "INVOICE_CREATE", "invoices", invoiceId, 
                                null, "Tạo hóa đơn cho lịch hẹn: " + appointmentId, clientIp, userAgent);
            
            return invoice;
        }
        
        throw new RuntimeException("Không thể tạo hóa đơn");
    }

    /**
     * Process offline payment (cash payment)
     */
    public Payment processOfflinePayment(String invoiceId, String userId, String clientIp, String userAgent) {
        Invoice invoice = invoiceDAO.findById(invoiceId);
        if (invoice == null) {
            throw new IllegalArgumentException("Hóa đơn không tồn tại");
        }

        if (invoice.isPaid()) {
            throw new IllegalStateException("Hóa đơn đã được thanh toán");
        }

        // Generate transaction reference
        String txnRef = "CASH_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8);

        // Create payment record
        Payment payment = new Payment();
        payment.setInvoiceId(invoiceId);
        payment.setPaymentMethod(Payment.METHOD_CASH);
        payment.setAmount(invoice.getTotalAmount());
        payment.setStatus(Payment.STATUS_SUCCESS);
        payment.setTxnRef(txnRef);
        payment.setOrderInfo("Thanh toán tại quầy - " + invoice.getDescription());
        payment.setClientIp(clientIp);
        payment.setSignatureVerified(true);
        payment.setProcessedAt(LocalDateTime.now());

        String paymentId = paymentDAO.create(payment);
        if (paymentId != null) {
            payment.setId(paymentId);
            
            // Update invoice status to PAID
            invoiceDAO.updateStatus(invoiceId, Invoice.STATUS_PAID, LocalDateTime.now());
            
            // Update appointment status to COMPLETED after payment
            if (invoice.getAppointmentId() != null) {
                appointmentDAO.updateStatus(invoice.getAppointmentId(), "COMPLETED");
            }
            
            // Log audit
            auditLogDAO.createLog(userId, "PAYMENT_OFFLINE_SUCCESS", "payments", paymentId, 
                                null, "Thanh toán tại quầy thành công - Số tiền: " + invoice.getTotalAmount(), 
                                clientIp, userAgent);
            
            return payment;
        }
        
        throw new RuntimeException("Không thể xử lý thanh toán");
    }

    /**
     * Prepare online payment (VNPay) - This would normally integrate with VNPay API
     * For now, we'll create a payment record and simulate the process
     */
    public Payment prepareOnlinePayment(String invoiceId, String userId, String clientIp, String userAgent) {
        Invoice invoice = invoiceDAO.findById(invoiceId);
        if (invoice == null) {
            throw new IllegalArgumentException("Hóa đơn không tồn tại");
        }

        if (invoice.isPaid()) {
            throw new IllegalStateException("Hóa đơn đã được thanh toán");
        }

        // Generate transaction reference
        String txnRef = "VNPAY_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8);

        // Create payment record
        Payment payment = new Payment();
        payment.setInvoiceId(invoiceId);
        payment.setPaymentMethod(Payment.METHOD_VNPAY);
        payment.setAmount(invoice.getTotalAmount());
        payment.setStatus(Payment.STATUS_PENDING);
        payment.setTxnRef(txnRef);
        payment.setOrderInfo("Thanh toán online - " + invoice.getDescription());
        payment.setClientIp(clientIp);
        payment.setExpiresAt(LocalDateTime.now().plusMinutes(15)); // 15 minutes expiry
        payment.setSignatureVerified(false);

        // In real implementation, this would call VNPay API to get payment URL
        String mockPaymentUrl = "/SkinAI/patient/payment/vnpay/mock?txnRef=" + txnRef;
        payment.setPaymentUrl(mockPaymentUrl);

        String paymentId = paymentDAO.create(payment);
        if (paymentId != null) {
            payment.setId(paymentId);
            
            // Log audit
            auditLogDAO.createLog(userId, "PAYMENT_ONLINE_INIT", "payments", paymentId, 
                                null, "Khởi tạo thanh toán online - TxnRef: " + txnRef, clientIp, userAgent);
            
            return payment;
        }
        
        throw new RuntimeException("Không thể khởi tạo thanh toán online");
    }

    /**
     * Process online payment success callback
     */
    public boolean processOnlinePaymentSuccess(String txnRef, String userId, String clientIp, String userAgent) {
        Payment payment = paymentDAO.findByTxnRef(txnRef);
        if (payment == null) {
            return false;
        }

        if (payment.isSuccess()) {
            return true; // Already processed
        }

        // Update payment status
        payment.setStatus(Payment.STATUS_SUCCESS);
        payment.setVnpResponseCode("00");
        payment.setVnpTransactionStatus("00");
        payment.setVnpPayDate(LocalDateTime.now().toString());
        payment.setSignatureVerified(true);
        payment.setProcessedAt(LocalDateTime.now());

        boolean updated = paymentDAO.update(payment);
        if (updated) {
            // Update invoice status to PAID
            invoiceDAO.updateStatus(payment.getInvoiceId(), Invoice.STATUS_PAID, LocalDateTime.now());
            
            // Update appointment status to COMPLETED after payment
            Invoice invoice = invoiceDAO.findById(payment.getInvoiceId());
            if (invoice != null && invoice.getAppointmentId() != null) {
                appointmentDAO.updateStatus(invoice.getAppointmentId(), "COMPLETED");
            }
            
            // Log audit
            auditLogDAO.createLog(userId, "PAYMENT_ONLINE_SUCCESS", "payments", payment.getId(), 
                                null, "Thanh toán online thành công - TxnRef: " + txnRef, clientIp, userAgent);
            
            return true;
        }
        
        return false;
    }

    /**
     * Process online payment failure
     */
    public boolean processOnlinePaymentFailure(String txnRef, String userId, String clientIp, String userAgent) {
        Payment payment = paymentDAO.findByTxnRef(txnRef);
        if (payment == null) {
            return false;
        }

        // Update payment status
        payment.setStatus(Payment.STATUS_FAILED);
        payment.setVnpResponseCode("99");
        payment.setProcessedAt(LocalDateTime.now());

        boolean updated = paymentDAO.update(payment);
        if (updated) {
            // Log audit
            auditLogDAO.createLog(userId, "PAYMENT_ONLINE_FAILED", "payments", payment.getId(), 
                                null, "Thanh toán online thất bại - TxnRef: " + txnRef, clientIp, userAgent);
            
            return true;
        }
        
        return false;
    }

    /**
     * Get invoice with appointment details for display
     */
    public InvoiceWithDetails getInvoiceWithDetails(String invoiceId) {
        Invoice invoice = invoiceDAO.findById(invoiceId);
        if (invoice == null) {
            return null;
        }

        Appointment appointment = appointmentDAO.findById(invoice.getAppointmentId());
        
        return new InvoiceWithDetails(invoice, appointment);
    }

    /**
     * Helper class to combine invoice and appointment data
     */
    public static class InvoiceWithDetails {
        private Invoice invoice;
        private Appointment appointment;

        public InvoiceWithDetails(Invoice invoice, Appointment appointment) {
            this.invoice = invoice;
            this.appointment = appointment;
        }

        public Invoice getInvoice() {
            return invoice;
        }

        public Appointment getAppointment() {
            return appointment;
        }
    }
}