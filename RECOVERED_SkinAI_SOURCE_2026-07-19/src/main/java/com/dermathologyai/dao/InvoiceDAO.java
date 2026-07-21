package com.dermathologyai.dao;

import com.dermathologyai.model.Invoice;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class InvoiceDAO extends DBContext {

    private static final String SELECT_COLS =
        "SELECT id, appointment_id, total_amount, status, description, paid_at, " +
        "created_at, updated_at FROM invoices";

    private static final String INSERT_SQL =
        "INSERT INTO invoices (appointment_id, total_amount, status, description) " +
        "OUTPUT INSERTED.id VALUES (?, ?, ?, ?)";

    public String create(Invoice invoice) {
        return insertReturningId(INSERT_SQL,
            invoice.getAppointmentId(),
            invoice.getTotalAmount(),
            invoice.getStatus(),
            invoice.getDescription()
        );
    }

    public Invoice findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", InvoiceDAO::mapRow, id);
    }

    public Invoice findByAppointmentId(String appointmentId) {
        return queryOne(SELECT_COLS + " WHERE appointment_id = ?", InvoiceDAO::mapRow, appointmentId);
    }

    public List<Invoice> findByStatus(String status) {
        return queryList(SELECT_COLS + " WHERE status = ? ORDER BY created_at DESC", 
                        InvoiceDAO::mapRow, status);
    }

    public boolean updateStatus(String id, String status) {
        return updateStatus(id, status, null);
    }

    public boolean updateStatus(String id, String status, LocalDateTime paidAt) {
        String sql = "UPDATE invoices SET status = ?, paid_at = ?, updated_at = SYSDATETIME() WHERE id = ?";
        return executeUpdate(sql, status, paidAt != null ? Timestamp.valueOf(paidAt) : null, id);
    }

    public boolean update(Invoice invoice) {
        String sql = "UPDATE invoices SET total_amount = ?, status = ?, description = ?, " +
                    "paid_at = ?, updated_at = SYSDATETIME() WHERE id = ?";
        
        Timestamp paidAtTimestamp = invoice.getPaidAt() != null ? 
                                   Timestamp.valueOf(invoice.getPaidAt()) : null;
        
        return executeUpdate(sql,
            invoice.getTotalAmount(),
            invoice.getStatus(),
            invoice.getDescription(),
            paidAtTimestamp,
            invoice.getId()
        );
    }

    public List<Invoice> findAll() {
        return queryList(SELECT_COLS + " ORDER BY created_at DESC", InvoiceDAO::mapRow);
    }

    public boolean delete(String id) {
        return executeUpdate("DELETE FROM invoices WHERE id = ?", id);
    }

    /**
     * Tạo invoice cho appointment nếu chưa có
     */
    public String createInvoiceForAppointment(String appointmentId, BigDecimal amount, String description) {
        // Kiểm tra xem đã có invoice cho appointment này chưa
        Invoice existingInvoice = findByAppointmentId(appointmentId);
        if (existingInvoice != null) {
            return existingInvoice.getId(); // Đã có rồi, trả về ID
        }

        // Tạo invoice mới
        Invoice invoice = new Invoice();
        invoice.setAppointmentId(appointmentId);
        invoice.setTotalAmount(amount);
        invoice.setStatus("PENDING");
        invoice.setDescription(description);

        return create(invoice);
    }

    /**
     * Lấy danh sách appointments chưa có invoice (CONFIRMED hoặc COMPLETED)
     */
    public List<String> findAppointmentsWithoutInvoice() {
        String sql = "SELECT a.id FROM appointments a " +
                    "LEFT JOIN invoices i ON a.id = i.appointment_id " +
                    "WHERE i.id IS NULL AND a.status IN ('CONFIRMED', 'COMPLETED')";
        
        return queryList(sql, (rs) -> rs.getString("id"));
    }

    /**
     * Đếm số lượng invoices theo patient ID
     */
    public int countByPatientId(String patientId) {
        String sql = "SELECT COUNT(*) FROM invoices i " +
                    "INNER JOIN appointments a ON i.appointment_id = a.id " +
                    "WHERE a.patient_id = ?";
        
        return queryScalar(sql, Integer.class, patientId);
    }

    /** Maps a patient's appointment IDs to their invoice IDs for read-only appointment details. */
    public Map<String, String> findInvoiceIdsByPatientId(String patientId) {
        String sql = "SELECT i.appointment_id, i.id FROM invoices i " +
                     "INNER JOIN appointments a ON a.id = i.appointment_id " +
                     "WHERE a.patient_id = ?";
        Map<String, String> invoiceIds = new HashMap<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) invoiceIds.put(rs.getString("appointment_id"), rs.getString("id"));
            }
        } catch (SQLException ignored) {
            // The appointment list can still render; legacy rows will use the create/view fallback.
        }
        return invoiceIds;
    }

    /**
     * Lấy tất cả appointments chưa có invoice (bất kể trạng thái)
     */
    public List<String> findAllAppointmentsWithoutInvoice() {
        String sql = "SELECT a.id FROM appointments a " +
                    "LEFT JOIN invoices i ON a.id = i.appointment_id " +
                    "WHERE i.id IS NULL";
        
        return queryList(sql, (rs) -> rs.getString("id"));
    }

    private static Invoice mapRow(ResultSet rs) throws SQLException {
        Invoice invoice = new Invoice();
        invoice.setId(rs.getString("id"));
        invoice.setAppointmentId(rs.getString("appointment_id"));
        invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
        invoice.setStatus(rs.getString("status"));
        invoice.setDescription(rs.getString("description"));
        
        Timestamp paidAt = rs.getTimestamp("paid_at");
        if (paidAt != null) {
            invoice.setPaidAt(paidAt.toLocalDateTime());
        }
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            invoice.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            invoice.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return invoice;
    }
}
