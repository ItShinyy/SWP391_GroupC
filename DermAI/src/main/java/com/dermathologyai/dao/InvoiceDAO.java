package com.dermathologyai.dao;

import com.dermathologyai.model.Invoice;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/** Invoice CRUD. PAID status updates are owned by payment-service. */
public class InvoiceDAO extends DBContext {

    private static final String ADMIN_BASE =
        "SELECT i.id, i.appointment_id, i.total_amount, i.status, i.description," +
        " i.paid_at, i.created_at, i.updated_at," +
        " u.full_name AS patient_name, a.appointment_time" +
        " FROM invoices i" +
        " LEFT JOIN appointments a ON i.appointment_id = a.id" +
        " LEFT JOIN patients p ON a.patient_id = p.id" +
        " LEFT JOIN users u ON p.user_id = u.id";

    private static final String SIMPLE_SELECT =
        "SELECT id, appointment_id, total_amount, status, description," +
        " paid_at, created_at, updated_at FROM invoices";

    public Invoice findById(String id) {
        return queryOne(SIMPLE_SELECT + " WHERE id = ?", InvoiceDAO::mapRow, id);
    }

    public Invoice findByAppointmentId(String appointmentId) {
        return queryOne(SIMPLE_SELECT + " WHERE appointment_id = ?", InvoiceDAO::mapRow, appointmentId);
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
            " INNER JOIN appointments a ON i.appointment_id = a.id WHERE a.patient_id = ?",
            patientId
        );
    }

    public BigDecimal sumCollectedRevenue()  { return sumByStatus("PAID"); }
    public BigDecimal sumOutstandingRevenue() { return sumByStatus("UNPAID"); }

    private BigDecimal sumByStatus(String status) {
        try (java.sql.Connection conn = getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT COALESCE(SUM(total_amount), 0) FROM invoices WHERE status = ?")) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (java.sql.SQLException e) { return BigDecimal.ZERO; }
    }

    public List<Invoice> findAllForAdmin(String search, String status,
                                         String startDate, String endDate,
                                         int page, int size) {
        StringBuilder sql = new StringBuilder(ADMIN_BASE + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, status, startDate, endDate);
        sql.append(" ORDER BY i.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * size);
        params.add(size);
        return queryList(sql.toString(), InvoiceDAO::mapRowAdmin, params.toArray());
    }

    public int countAllForAdmin(String search, String status,
                                 String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM invoices i" +
            " LEFT JOIN appointments a ON i.appointment_id = a.id" +
            " LEFT JOIN patients p ON a.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, status, startDate, endDate);
        try (java.sql.Connection conn = getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) { return rs.next() ? rs.getInt(1) : 0; }
        } catch (java.sql.SQLException e) { return 0; }
    }

    private static void appendFilters(StringBuilder sql, List<Object> params,
                                       String search, String status,
                                       String startDate, String endDate) {
        if (search != null && !search.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR i.id LIKE ?)");
            String like = "%" + search.trim() + "%";
            params.add(like); params.add(like);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND i.status = ?");
            params.add(status.trim().toUpperCase());
        }
        if (startDate != null && !startDate.isBlank()) {
            sql.append(" AND CAST(i.created_at AS DATE) >= ?");
            params.add(startDate.trim());
        }
        if (endDate != null && !endDate.isBlank()) {
            sql.append(" AND CAST(i.created_at AS DATE) <= ?");
            params.add(endDate.trim());
        }
    }

    private static Invoice mapRow(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setId(rs.getString("id"));
        inv.setAppointmentId(rs.getString("appointment_id"));
        inv.setTotalAmount(rs.getBigDecimal("total_amount"));
        inv.setStatus(rs.getString("status"));
        inv.setDescription(rs.getString("description"));
        Timestamp t = rs.getTimestamp("paid_at");    if (t != null) inv.setPaidAt(t.toLocalDateTime());
        Timestamp c = rs.getTimestamp("created_at"); if (c != null) inv.setCreatedAt(c.toLocalDateTime());
        Timestamp u = rs.getTimestamp("updated_at"); if (u != null) inv.setUpdatedAt(u.toLocalDateTime());
        return inv;
    }

    private static Invoice mapRowAdmin(ResultSet rs) throws SQLException {
        Invoice inv = mapRow(rs);
        try { inv.setPatientName(rs.getString("patient_name")); } catch (SQLException ignored) {}
        try {
            Timestamp t = rs.getTimestamp("appointment_time");
            if (t != null) inv.setAppointmentTime(t.toLocalDateTime());
        } catch (SQLException ignored) {}
        return inv;
    }
}