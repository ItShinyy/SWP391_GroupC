package com.dermathologyai.dao;

import com.dermathologyai.model.Invoice;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/** Invoice CRUD for Java. PAID updates are owned by payment-service. */
public class InvoiceDAO extends DBContext {

    public Invoice findById(String id) {
        return queryOne("SELECT id, appointment_id, total_amount, status, description, paid_at, created_at, updated_at FROM invoices WHERE id = ?",
            InvoiceDAO::mapRow, id);
    }

    public Invoice findByAppointmentId(String appointmentId) {
        return queryOne("SELECT id, appointment_id, total_amount, status, description, paid_at, created_at, updated_at FROM invoices WHERE appointment_id = ?",
            InvoiceDAO::mapRow, appointmentId);
    }

    public String createUnpaid(String appointmentId, BigDecimal amount, String description) {
        return insertReturningId(
            "INSERT INTO invoices (id, appointment_id, total_amount, status, description, created_at, updated_at)" +
            " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, 'UNPAID', ?, SYSUTCDATETIME(), SYSUTCDATETIME())",
            appointmentId, amount, description
        );
    }

    public boolean markCancelled(String id) {
        return executeUpdate(
            "UPDATE invoices SET status = 'CANCELLED', updated_at = SYSUTCDATETIME() WHERE id = ? AND status = 'UNPAID'",
            id
        );
    }

    public int countByStatus(String status) {
        return queryScalar("SELECT COUNT(*) FROM invoices WHERE status = ?", status);
    }

    public int countByPatientId(String patientId) {
        return queryScalar(
            "SELECT COUNT(*) FROM invoices i" +
            " INNER JOIN appointments a ON i.appointment_id = a.id" +
            " WHERE a.patient_id = ?",
            patientId
        );
    }

    private static Invoice mapRow(ResultSet rs) throws SQLException {
        Invoice invoice = new Invoice();
        invoice.setId(rs.getString("id"));
        invoice.setAppointmentId(rs.getString("appointment_id"));
        invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
        invoice.setStatus(rs.getString("status"));
        invoice.setDescription(rs.getString("description"));
        Timestamp paid = rs.getTimestamp("paid_at");
        if (paid != null) invoice.setPaidAt(paid.toLocalDateTime());
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) invoice.setCreatedAt(created.toLocalDateTime());
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) invoice.setUpdatedAt(updated.toLocalDateTime());
        return invoice;
    }
}
