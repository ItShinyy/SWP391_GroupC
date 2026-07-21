package com.dermathologyai.dao;

import com.dermathologyai.model.Payment;
import com.dermathologyai.model.PaymentHistory;
import com.dermathologyai.model.Invoice;
import com.dermathologyai.model.PaymentNotificationData;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PaymentDAO extends DBContext {

    private static final String SELECT_COLS =
        "SELECT id, invoice_id, payment_method, amount, status, txn_ref, order_info, " +
        "payment_url, client_ip, expires_at, vnp_transaction_no, vnp_bank_code, " +
        "vnp_bank_tran_no, vnp_card_type, vnp_response_code, vnp_transaction_status, " +
        "vnp_pay_date, signature_verified, callback_payload, created_at, updated_at, " +
        "processed_at FROM payments";

    private static final String INSERT_SQL =
        "INSERT INTO payments (invoice_id, payment_method, amount, status, txn_ref, " +
        "order_info, payment_url, client_ip, expires_at, signature_verified) " +
        "OUTPUT INSERTED.id VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    public String create(Payment payment) {
        Timestamp expiresAtTimestamp = payment.getExpiresAt() != null ? 
                                      Timestamp.valueOf(payment.getExpiresAt()) : null;

        return insertReturningId(INSERT_SQL,
            payment.getInvoiceId(),
            payment.getPaymentMethod(),
            payment.getAmount(),
            payment.getStatus(),
            payment.getTxnRef(),
            payment.getOrderInfo(),
            payment.getPaymentUrl(),
            payment.getClientIp(),
            expiresAtTimestamp,
            payment.isSignatureVerified()
        );
    }

    public Payment findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", PaymentDAO::mapRow, id);
    }

    public Payment findByTxnRef(String txnRef) {
        return queryOne(SELECT_COLS + " WHERE txn_ref = ?", PaymentDAO::mapRow, txnRef);
    }

    public List<Payment> findByInvoiceId(String invoiceId) {
        return queryList(SELECT_COLS + " WHERE invoice_id = ? ORDER BY created_at DESC", 
                        PaymentDAO::mapRow, invoiceId);
    }

    public List<Payment> findByStatus(String status) {
        return queryList(SELECT_COLS + " WHERE status = ? ORDER BY created_at DESC", 
                        PaymentDAO::mapRow, status);
    }

    public boolean updateStatus(String id, String status) {
        return executeUpdate("UPDATE payments SET status = ?, updated_at = SYSDATETIME() WHERE id = ?", 
                           status, id);
    }

    public boolean updateVnpayCallback(String id, String vnpTransactionNo, String vnpBankCode,
                                     String vnpBankTranNo, String vnpCardType, String vnpResponseCode,
                                     String vnpTransactionStatus, String vnpPayDate, 
                                     boolean signatureVerified, String callbackPayload) {
        String sql = "UPDATE payments SET vnp_transaction_no = ?, vnp_bank_code = ?, " +
                    "vnp_bank_tran_no = ?, vnp_card_type = ?, vnp_response_code = ?, " +
                    "vnp_transaction_status = ?, vnp_pay_date = ?, signature_verified = ?, " +
                    "callback_payload = ?, processed_at = SYSDATETIME(), updated_at = SYSDATETIME() " +
                    "WHERE id = ?";
        
        return executeUpdate(sql,
            vnpTransactionNo, vnpBankCode, vnpBankTranNo, vnpCardType,
            vnpResponseCode, vnpTransactionStatus, vnpPayDate,
            signatureVerified, callbackPayload, id
        );
    }

    public boolean update(Payment payment) {
        String sql = "UPDATE payments SET payment_method = ?, amount = ?, status = ?, " +
                    "order_info = ?, payment_url = ?, client_ip = ?, expires_at = ?, " +
                    "vnp_transaction_no = ?, vnp_bank_code = ?, vnp_bank_tran_no = ?, " +
                    "vnp_card_type = ?, vnp_response_code = ?, vnp_transaction_status = ?, " +
                    "vnp_pay_date = ?, signature_verified = ?, callback_payload = ?, " +
                    "processed_at = ?, updated_at = SYSDATETIME() WHERE id = ?";
        
        Timestamp expiresAtTimestamp = payment.getExpiresAt() != null ? 
                                      Timestamp.valueOf(payment.getExpiresAt()) : null;
        Timestamp processedAtTimestamp = payment.getProcessedAt() != null ? 
                                        Timestamp.valueOf(payment.getProcessedAt()) : null;
        
        return executeUpdate(sql,
            payment.getPaymentMethod(),
            payment.getAmount(),
            payment.getStatus(),
            payment.getOrderInfo(),
            payment.getPaymentUrl(),
            payment.getClientIp(),
            expiresAtTimestamp,
            payment.getVnpTransactionNo(),
            payment.getVnpBankCode(),
            payment.getVnpBankTranNo(),
            payment.getVnpCardType(),
            payment.getVnpResponseCode(),
            payment.getVnpTransactionStatus(),
            payment.getVnpPayDate(),
            payment.isSignatureVerified(),
            payment.getCallbackPayload(),
            processedAtTimestamp,
            payment.getId()
        );
    }

    public List<Payment> findAll() {
        return queryList(SELECT_COLS + " ORDER BY created_at DESC", PaymentDAO::mapRow);
    }

    public List<Payment> findByPatientId(String patientId) {
        String sql = SELECT_COLS + " p " +
                    "INNER JOIN invoices i ON p.invoice_id = i.id " +
                    "INNER JOIN appointments a ON i.appointment_id = a.id " +
                    "WHERE a.patient_id = ? ORDER BY p.created_at DESC";
        
        return queryList(sql, PaymentDAO::mapRow, patientId);
    }

    public List<String> findPendingCashAppointmentIdsByPatientId(String patientId) {
        String sql = "SELECT DISTINCT i.appointment_id " +
                    "FROM payments p " +
                    "INNER JOIN invoices i ON p.invoice_id = i.id " +
                    "INNER JOIN appointments a ON i.appointment_id = a.id " +
                    "WHERE a.patient_id = ? AND a.status <> 'CANCELLED' " +
                    "AND p.payment_method = 'CASH' AND p.status = 'PENDING'";
        return queryList(sql, rs -> rs.getString("appointment_id"), patientId);
    }

    /** Returns the payment state for every appointment displayed to one patient. */
    public Map<String, String> findPaymentStatusesByPatientId(String patientId) {
        String sql = "SELECT a.id AS appointment_id, " +
                    "CASE " +
                    " WHEN a.status = 'CANCELLED' THEN 'CANCELLED' " +
                    " WHEN i.status = 'PAID' THEN 'PAID' " +
                    " WHEN EXISTS (SELECT 1 FROM payments p WHERE p.invoice_id = i.id AND p.status = 'PENDING') THEN 'PENDING' " +
                    " ELSE 'UNPAID' END AS payment_status " +
                    "FROM appointments a " +
                    "LEFT JOIN invoices i ON i.appointment_id = a.id " +
                    "WHERE a.patient_id = ?";
        Map<String, String> statuses = new HashMap<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    statuses.put(rs.getString("appointment_id"), rs.getString("payment_status"));
                }
            }
        } catch (SQLException ignored) {
            // The page can still render a safe UNPAID fallback if payment data is unavailable.
        }
        return statuses;
    }

    public int countByPatientId(String patientId) {
        String sql = "SELECT COUNT(*) FROM payments p " +
                    "INNER JOIN invoices i ON p.invoice_id = i.id " +
                    "INNER JOIN appointments a ON i.appointment_id = a.id " +
                    "WHERE a.patient_id = ?";
        
        return queryScalar(sql, patientId);
    }

    public List<PaymentHistory> findPaymentHistoryByPatientId(String patientId, int page, int pageSize) {
        String sql = "SELECT p.id as payment_id, p.invoice_id, p.payment_method, p.amount, p.status as payment_status, " +
                    "p.txn_ref, p.order_info, p.payment_url, p.client_ip, p.expires_at, " +
                    "p.vnp_transaction_no, p.vnp_bank_code, p.vnp_bank_tran_no, p.vnp_card_type, " +
                    "p.vnp_response_code, p.vnp_transaction_status, p.vnp_pay_date, " +
                    "p.signature_verified, p.callback_payload, p.created_at as payment_created_at, " +
                    "p.updated_at as payment_updated_at, p.processed_at, " +
                    "i.id as invoice_id, i.appointment_id, i.total_amount, i.status as invoice_status, " +
                    "i.description, i.paid_at, i.created_at as invoice_created_at, " +
                    "i.updated_at as invoice_updated_at, " +
                    "c.clinic_name, a.appointment_time " +
                    "FROM payments p " +
                    "INNER JOIN invoices i ON p.invoice_id = i.id " +
                    "INNER JOIN appointments a ON i.appointment_id = a.id " +
                    "INNER JOIN clinics c ON a.clinic_id = c.id " +
                    "WHERE a.patient_id = ? " +
                    "ORDER BY p.created_at DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        return queryList(sql, PaymentDAO::mapPaymentHistory, patientId, (page - 1) * pageSize, pageSize);
    }

    /**
     * Finds invoices committed as PAID that have not produced a success notification.
     * enabled_at prevents historical invoices from being emailed after first deploy.
     */
    public List<PaymentNotificationData> findPaidInvoicesWithoutSuccessNotification() {
        String sql = "SELECT i.id AS invoice_id, i.appointment_id, i.total_amount, i.description, i.paid_at, " +
            "u.id AS user_id, u.full_name AS patient_name, c.clinic_name, " +
            "COALESCE(doctor_user.full_name, N'Bác sĩ chưa xác định') AS doctor_name, " +
            "a.appointment_time, payment.payment_method, payment.txn_ref " +
            "FROM dbo.invoices i " +
            "INNER JOIN dbo.appointments a ON a.id = i.appointment_id " +
            "INNER JOIN dbo.patients patient ON patient.id = a.patient_id " +
            "INNER JOIN dbo.users u ON u.id = patient.user_id " +
            "INNER JOIN dbo.clinics c ON c.id = a.clinic_id " +
            "LEFT JOIN dbo.doctors d ON d.id = a.doctor_id " +
            "LEFT JOIN dbo.users doctor_user ON doctor_user.id = d.user_id " +
            "OUTER APPLY (SELECT TOP 1 p.payment_method, p.txn_ref " +
            "FROM dbo.payments p WHERE p.invoice_id = i.id AND p.status = 'SUCCESS' " +
            "ORDER BY p.processed_at DESC, p.created_at DESC) payment " +
            "INNER JOIN dbo.notification_job_settings settings " +
            "ON settings.job_name = 'PAYMENT_SUCCESS_EMAIL' " +
            "LEFT JOIN dbo.notifications n ON n.event_key = CONCAT('payment:', i.id, ':success') " +
            "WHERE i.status = 'PAID' AND i.paid_at IS NOT NULL " +
            "AND i.paid_at >= settings.enabled_at AND n.id IS NULL " +
            "ORDER BY i.paid_at ASC";
        return queryList(sql, PaymentDAO::mapPaymentNotificationData);
    }

    public boolean delete(String id) {
        return executeUpdate("DELETE FROM payments WHERE id = ?", id);
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
        
        Timestamp expiresAt = rs.getTimestamp("expires_at");
        if (expiresAt != null) {
            payment.setExpiresAt(expiresAt.toLocalDateTime());
        }
        
        payment.setVnpTransactionNo(rs.getString("vnp_transaction_no"));
        payment.setVnpBankCode(rs.getString("vnp_bank_code"));
        payment.setVnpBankTranNo(rs.getString("vnp_bank_tran_no"));
        payment.setVnpCardType(rs.getString("vnp_card_type"));
        payment.setVnpResponseCode(rs.getString("vnp_response_code"));
        payment.setVnpTransactionStatus(rs.getString("vnp_transaction_status"));
        payment.setVnpPayDate(rs.getString("vnp_pay_date"));
        payment.setSignatureVerified(rs.getBoolean("signature_verified"));
        payment.setCallbackPayload(rs.getString("callback_payload"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            payment.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            payment.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        Timestamp processedAt = rs.getTimestamp("processed_at");
        if (processedAt != null) {
            payment.setProcessedAt(processedAt.toLocalDateTime());
        }
        
        return payment;
    }

    private static PaymentHistory mapPaymentHistory(ResultSet rs) throws SQLException {
        // Map Payment
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
        if (expiresAt != null) {
            payment.setExpiresAt(expiresAt.toLocalDateTime());
        }
        
        payment.setVnpTransactionNo(rs.getString("vnp_transaction_no"));
        payment.setVnpBankCode(rs.getString("vnp_bank_code"));
        payment.setVnpBankTranNo(rs.getString("vnp_bank_tran_no"));
        payment.setVnpCardType(rs.getString("vnp_card_type"));
        payment.setVnpResponseCode(rs.getString("vnp_response_code"));
        payment.setVnpTransactionStatus(rs.getString("vnp_transaction_status"));
        payment.setVnpPayDate(rs.getString("vnp_pay_date"));
        payment.setSignatureVerified(rs.getBoolean("signature_verified"));
        payment.setCallbackPayload(rs.getString("callback_payload"));
        
        Timestamp paymentCreatedAt = rs.getTimestamp("payment_created_at");
        if (paymentCreatedAt != null) {
            payment.setCreatedAt(paymentCreatedAt.toLocalDateTime());
        }
        
        Timestamp paymentUpdatedAt = rs.getTimestamp("payment_updated_at");
        if (paymentUpdatedAt != null) {
            payment.setUpdatedAt(paymentUpdatedAt.toLocalDateTime());
        }
        
        Timestamp processedAt = rs.getTimestamp("processed_at");
        if (processedAt != null) {
            payment.setProcessedAt(processedAt.toLocalDateTime());
        }

        // Map Invoice
        Invoice invoice = new Invoice();
        invoice.setId(rs.getString("invoice_id"));
        invoice.setAppointmentId(rs.getString("appointment_id"));
        invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
        invoice.setStatus(rs.getString("invoice_status"));
        invoice.setDescription(rs.getString("description"));
        
        Timestamp paidAt = rs.getTimestamp("paid_at");
        if (paidAt != null) {
            invoice.setPaidAt(paidAt.toLocalDateTime());
        }
        
        Timestamp invoiceCreatedAt = rs.getTimestamp("invoice_created_at");
        if (invoiceCreatedAt != null) {
            invoice.setCreatedAt(invoiceCreatedAt.toLocalDateTime());
        }
        
        Timestamp invoiceUpdatedAt = rs.getTimestamp("invoice_updated_at");
        if (invoiceUpdatedAt != null) {
            invoice.setUpdatedAt(invoiceUpdatedAt.toLocalDateTime());
        }

        // Map additional info
        String clinicName = rs.getString("clinic_name");
        Timestamp appointmentTime = rs.getTimestamp("appointment_time");
        LocalDateTime appointmentDateTime = appointmentTime != null ? appointmentTime.toLocalDateTime() : null;

        return new PaymentHistory(payment, invoice, clinicName, appointmentDateTime, invoice.getAppointmentId());
    }

    private static PaymentNotificationData mapPaymentNotificationData(ResultSet rs) throws SQLException {
        PaymentNotificationData data = new PaymentNotificationData();
        data.setInvoiceId(rs.getString("invoice_id"));
        data.setAppointmentId(rs.getString("appointment_id"));
        data.setUserId(rs.getString("user_id"));
        data.setPatientName(rs.getString("patient_name"));
        data.setClinicName(rs.getString("clinic_name"));
        data.setDoctorName(rs.getString("doctor_name"));
        data.setDescription(rs.getString("description"));
        data.setPaymentMethod(rs.getString("payment_method"));
        data.setTransactionReference(rs.getString("txn_ref"));
        data.setAmount(rs.getBigDecimal("total_amount"));
        Timestamp appointmentTime = rs.getTimestamp("appointment_time");
        if (appointmentTime != null) data.setAppointmentTime(appointmentTime.toLocalDateTime());
        Timestamp paidAt = rs.getTimestamp("paid_at");
        if (paidAt != null) data.setPaidAt(paidAt.toLocalDateTime());
        return data;
    }
}
