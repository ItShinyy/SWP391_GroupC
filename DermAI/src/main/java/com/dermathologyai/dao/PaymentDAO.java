package com.dermathologyai.dao;

import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.Payment;
import com.dermathologyai.model.PaymentHistory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/** Payment read model + cancel helpers. VNPay writes are owned by payment-service. */
public class PaymentDAO extends DBContext {
    private static final Logger LOG = Logger.getLogger(PaymentDAO.class.getName());
    private static final String SELECT_COLS =
        "id, invoice_id, payment_method, amount, status, txn_ref, order_info, payment_url, client_ip, expires_at," +
        " vnp_transaction_no, vnp_response_code, vnp_transaction_status, signature_verified, callback_payload, created_at, processed_at";

    public Payment findLatestByInvoiceId(String invoiceId) {
        return queryOne(
            "SELECT TOP 1 " + SELECT_COLS + " FROM payments WHERE invoice_id = ? ORDER BY created_at DESC",
            PaymentDAO::mapRow, invoiceId
        );
    }

    public int failPendingByInvoiceId(String invoiceId) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "UPDATE payments SET status = 'FAILED', processed_at = SYSUTCDATETIME(), updated_at = SYSUTCDATETIME()" +
                 " WHERE invoice_id = ? AND status = 'PENDING'")) {
            ps.setString(1, invoiceId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "failPendingByInvoiceId failed", e);
            return 0;
        }
    }

    public int countByStatus(String status) {
        return queryScalar("SELECT COUNT(*) FROM payments WHERE status = ?", status);
    }

    public List<PaymentHistory> findPaymentHistoryByPatientId(String patientId, int page, int pageSize) {
        String sql = "SELECT p.id AS payment_id, p.invoice_id, p.payment_method, p.amount, p.status AS payment_status," +
            " p.txn_ref, p.order_info, p.payment_url, p.client_ip, p.expires_at," +
            " p.vnp_transaction_no, p.vnp_response_code, p.vnp_transaction_status," +
            " p.signature_verified, p.callback_payload, p.created_at AS payment_created_at," +
            " p.processed_at, i.appointment_id, i.total_amount, i.status AS invoice_status," +
            " i.description, i.paid_at, i.created_at AS invoice_created_at," +
            " i.updated_at AS invoice_updated_at, c.clinic_name, a.appointment_time" +
            " FROM payments p" +
            " INNER JOIN invoices i ON p.invoice_id = i.id" +
            " INNER JOIN appointments a ON i.appointment_id = a.id" +
            " INNER JOIN clinics c ON a.clinic_id = c.id" +
            " WHERE a.patient_id = ?" +
            " ORDER BY p.created_at DESC" +
            " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        return queryList(sql, PaymentDAO::mapPaymentHistory, patientId, (page - 1) * pageSize, pageSize);
    }

    public int countPaymentHistoryByPatientId(String patientId) {
        return queryScalar(
            "SELECT COUNT(*) FROM payments p" +
            " INNER JOIN invoices i ON p.invoice_id = i.id" +
            " INNER JOIN appointments a ON i.appointment_id = a.id" +
            " WHERE a.patient_id = ?",
            patientId
        );
    }

    private static Payment mapRow(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setId(rs.getString("id"));
        payment.setInvoiceId(rs.getString("invoice_id"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setStatus(rs.getString("status"));
        payment.setTxnRef(rs.getString("txn_ref"));
        payment.setOrderInfo(rs.getString("order_info"));
        payment.setPaymentUrl(rs.getString("payment_url"));
        payment.setClientIp(rs.getString("client_ip"));
        Timestamp expires = rs.getTimestamp("expires_at");
        if (expires != null) payment.setExpiresAt(expires.toLocalDateTime());
        payment.setVnpTransactionNo(rs.getString("vnp_transaction_no"));
        payment.setVnpResponseCode(rs.getString("vnp_response_code"));
        payment.setVnpTransactionStatus(rs.getString("vnp_transaction_status"));
        payment.setSignatureVerified(rs.getBoolean("signature_verified"));
        payment.setCallbackPayload(rs.getString("callback_payload"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) payment.setCreatedAt(created.toLocalDateTime());
        Timestamp processed = rs.getTimestamp("processed_at");
        if (processed != null) payment.setProcessedAt(processed.toLocalDateTime());
        return payment;
    }

    private static PaymentHistory mapPaymentHistory(ResultSet rs) throws SQLException {
        Payment payment = new Payment();
        payment.setId(rs.getString("payment_id"));
        payment.setInvoiceId(rs.getString("invoice_id"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setAmount(rs.getBigDecimal("amount"));
        payment.setStatus(rs.getString("payment_status"));
        payment.setTxnRef(rs.getString("txn_ref"));
        payment.setOrderInfo(rs.getString("order_info"));
        payment.setPaymentUrl(rs.getString("payment_url"));
        payment.setClientIp(rs.getString("client_ip"));
        Timestamp expiresAt = rs.getTimestamp("expires_at");
        if (expiresAt != null) payment.setExpiresAt(expiresAt.toLocalDateTime());
        payment.setVnpTransactionNo(rs.getString("vnp_transaction_no"));
        payment.setVnpResponseCode(rs.getString("vnp_response_code"));
        payment.setVnpTransactionStatus(rs.getString("vnp_transaction_status"));
        payment.setSignatureVerified(rs.getBoolean("signature_verified"));
        payment.setCallbackPayload(rs.getString("callback_payload"));
        Timestamp paymentCreatedAt = rs.getTimestamp("payment_created_at");
        if (paymentCreatedAt != null) payment.setCreatedAt(paymentCreatedAt.toLocalDateTime());
        Timestamp processedAt = rs.getTimestamp("processed_at");
        if (processedAt != null) payment.setProcessedAt(processedAt.toLocalDateTime());

        Invoice invoice = new Invoice();
        invoice.setId(rs.getString("invoice_id"));
        invoice.setAppointmentId(rs.getString("appointment_id"));
        invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
        invoice.setStatus(rs.getString("invoice_status"));
        invoice.setDescription(rs.getString("description"));
        Timestamp paidAt = rs.getTimestamp("paid_at");
        if (paidAt != null) invoice.setPaidAt(paidAt.toLocalDateTime());
        Timestamp invoiceCreatedAt = rs.getTimestamp("invoice_created_at");
        if (invoiceCreatedAt != null) invoice.setCreatedAt(invoiceCreatedAt.toLocalDateTime());
        Timestamp invoiceUpdatedAt = rs.getTimestamp("invoice_updated_at");
        if (invoiceUpdatedAt != null) invoice.setUpdatedAt(invoiceUpdatedAt.toLocalDateTime());

        String clinicName = rs.getString("clinic_name");
        Timestamp appointmentTime = rs.getTimestamp("appointment_time");
        LocalDateTime appointmentDateTime = appointmentTime != null ? appointmentTime.toLocalDateTime() : null;
        return new PaymentHistory(payment, invoice, clinicName, appointmentDateTime, invoice.getAppointmentId());
    }
}
