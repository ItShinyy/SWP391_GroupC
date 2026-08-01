package com.dermathologyai.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Payment + invoice row for patient invoice history. */
public class PaymentHistory {
    private Payment payment;
    private Invoice invoice;
    private String clinicName;
    private LocalDateTime appointmentTime;
    private String appointmentId;

    public PaymentHistory() {}

    public PaymentHistory(Payment payment, Invoice invoice, String clinicName,
                          LocalDateTime appointmentTime, String appointmentId) {
        this.payment = payment;
        this.invoice = invoice;
        this.clinicName = clinicName;
        this.appointmentTime = appointmentTime;
        this.appointmentId = appointmentId;
    }

    public Payment getPayment() { return payment; }
    public void setPayment(Payment payment) { this.payment = payment; }
    public Invoice getInvoice() { return invoice; }
    public void setInvoice(Invoice invoice) { this.invoice = invoice; }
    public String getClinicName() { return clinicName; }
    public void setClinicName(String clinicName) { this.clinicName = clinicName; }
    public LocalDateTime getAppointmentTime() { return appointmentTime; }
    public void setAppointmentTime(LocalDateTime appointmentTime) { this.appointmentTime = appointmentTime; }
    public String getAppointmentId() { return appointmentId; }
    public void setAppointmentId(String appointmentId) { this.appointmentId = appointmentId; }

    public String getPaymentId() {
        return payment != null ? payment.getId() : null;
    }

    public String getInvoiceId() {
        return invoice != null ? invoice.getId() : null;
    }

    public BigDecimal getAmount() {
        return payment != null ? payment.getAmount() : null;
    }

    public String getPaymentMethod() {
        return payment != null ? payment.getPaymentMethod() : null;
    }

    public String getPaymentStatus() {
        return payment != null ? payment.getStatus() : null;
    }

    public String getInvoiceStatus() {
        return invoice != null ? invoice.getStatus() : null;
    }

    public LocalDateTime getPaymentDate() {
        return payment != null ? payment.getCreatedAt() : null;
    }

    public LocalDateTime getPaidAt() {
        return invoice != null ? invoice.getPaidAt() : null;
    }

    public String getDescription() {
        return invoice != null ? invoice.getDescription() : null;
    }

    public String getTxnRef() {
        return payment != null ? payment.getTxnRef() : null;
    }

    public boolean isPaid() {
        return payment != null && "SUCCESS".equals(payment.getStatus())
                && invoice != null && "PAID".equals(invoice.getStatus());
    }
}
