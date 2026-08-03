package com.dermathologyai.service;

import com.dermathologyai.config.AppConfig;
import com.dermathologyai.dao.InvoiceDAO;
import com.dermathologyai.dao.PaymentDAO;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.Payment;

import java.math.BigDecimal;

/**
 * Java-side invoice owner and payment read model.
 * Payment creation, VNPay signing, callbacks and expiry are owned by payment-service.
 */
public class BillingService {
    private final InvoiceDAO invoiceDAO = new InvoiceDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final AuditService auditService = new AuditService();

    public Invoice ensureUnpaidInvoiceForAppointment(String appointmentId) {
        Invoice existing = invoiceDAO.findByAppointmentId(appointmentId);
        if (existing != null) return existing;

        BigDecimal fee = defaultFee();
        String shortId = appointmentId.substring(0, Math.min(8, appointmentId.length()));
        String id = invoiceDAO.createUnpaid(appointmentId, fee, "Phí khám da liễu — lịch hẹn " + shortId);
        return id == null ? invoiceDAO.findByAppointmentId(appointmentId) : invoiceDAO.findById(id);
    }

    public Invoice findByAppointmentId(String appointmentId) {
        return invoiceDAO.findByAppointmentId(appointmentId);
    }

    public Invoice findById(String invoiceId) {
        return invoiceDAO.findById(invoiceId);
    }

    public Payment findLatestPayment(String invoiceId) {
        return paymentDAO.findLatestByInvoiceId(invoiceId);
    }

    /** Close open billing after a patient cancels an appointment. */
    public void cancelBillingForAppointment(String appointmentId) {
        Invoice invoice = invoiceDAO.findByAppointmentId(appointmentId);
        if (invoice == null || !"UNPAID".equals(invoice.getStatus())) return;

        paymentDAO.failPendingByInvoiceId(invoice.getId());
        invoiceDAO.markCancelled(invoice.getId());
        auditService.log(null, "BILLING_CANCEL_ON_APPT", "invoices", invoice.getId(),
            "{\"status\":\"UNPAID\"}", "{\"status\":\"CANCELLED\"}", null, null, null);
    }

    public int countInvoicesByStatus(String status) {
        return invoiceDAO.countByStatus(status);
    }

    public int countPaymentsByStatus(String status) {
        return paymentDAO.countByStatus(status);
    }

    /** Total collected (PAID invoices). */
    public java.math.BigDecimal sumCollectedRevenue() {
        return invoiceDAO.sumCollectedRevenue();
    }

    /** Total outstanding (UNPAID invoices). */
    public java.math.BigDecimal sumOutstandingRevenue() {
        return invoiceDAO.sumOutstandingRevenue();
    }

    private BigDecimal defaultFee() {
        String raw = AppConfig.get("billing.default.consultation.fee", "200000");
        try {
            BigDecimal fee = new BigDecimal(raw.trim());
            if (fee.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("fee must be positive");
            }
            return fee;
        } catch (RuntimeException e) {
            throw new IllegalStateException("Invalid billing.default.consultation.fee", e);
        }
    }
}
