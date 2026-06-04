package com.skinai.dal;

import com.skinai.model.AuditLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the audit_logs table.
 * Supports filtered/paginated queries for the admin UI.
 */
public class AuditLogDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogDAO.class);

    private static final String SELECT_COLS =
        "SELECT a.id, a.user_id, a.action, a.entity_type, a.record_id," +
        " a.old_values, a.new_values, a.ip_address, a.user_agent, a.status, a.error_message, a.created_at," +
        " u.full_name AS user_name, u.email AS user_email" +
        " FROM audit_logs a LEFT JOIN users u ON a.user_id = u.id";

    public AuditLog findById(String id) {
        return queryOne(SELECT_COLS + " WHERE a.id = ?", AuditLogDAO::mapRow, id);
    }

    public List<AuditLog> findAll(String keyword, String status, String startDate, String endDate, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_COLS + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, status, startDate, endDate);
        sql.append(" ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        return queryList(sql.toString(), AuditLogDAO::mapRow, params.toArray());
    }

    /** No-filter overload for simple pagination. */
    public List<AuditLog> findAll(int page, int pageSize) {
        return findAll(null, null, null, null, page, pageSize);
    }

    public int countAll(String keyword, String status, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM audit_logs a LEFT JOIN users u ON a.user_id = u.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, status, startDate, endDate);
        return queryScalar(sql.toString(), params.toArray());
    }

    /** No-filter overload. */
    public int countAll() {
        return countAll(null, null, null, null);
    }

    public String create(AuditLog log) {
        String error = log.getErrorMessage();
        if (error != null && error.length() > 1000) {
            error = error.substring(0, 1000);
        }
        String status = log.getStatus();
        if (status == null || status.isBlank()) {
            status = "SUCCESS";
        }

        String sql = "INSERT INTO audit_logs (id, user_id, action, entity_type, record_id," +
                     " old_values, new_values, ip_address, user_agent, status, error_message)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return insertReturningId(sql,
            log.getUserId(), log.getAction(), log.getEntityType(), log.getRecordId(),
            log.getOldValues(), log.getNewValues(), log.getIpAddress(), log.getUserAgent(),
            status, error
        );
    }

    // ─── Internal helpers ──────────────────────────────────────────────────────

    private static void appendFilters(StringBuilder sql, List<Object> params,
                                      String keyword, String status, String startDate, String endDate) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (u.email LIKE ? OR u.full_name LIKE ? OR a.ip_address LIKE ? OR CAST(a.user_id AS VARCHAR(36)) LIKE ? OR CAST(a.id AS VARCHAR(36)) LIKE ?)");
            String p = "%" + keyword.trim() + "%";
            params.add(p); params.add(p); params.add(p); params.add(p); params.add(p);
        }
        if (status != null && !status.isBlank() && !status.equals("ALL")) {
            sql.append(" AND a.status = ?");
            params.add(status.trim());
        }
        if (startDate != null && !startDate.isBlank()) {
            sql.append(" AND a.created_at >= ?");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.isBlank()) {
            sql.append(" AND a.created_at <= ?");
            params.add(endDate.trim() + " 23:59:59");
        }
    }

    private static AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog a = new AuditLog();
        a.setId(rs.getString("id"));
        a.setUserId(rs.getString("user_id"));
        a.setAction(rs.getString("action"));
        a.setEntityType(rs.getString("entity_type"));
        a.setRecordId(rs.getString("record_id"));
        a.setOldValues(rs.getString("old_values"));
        a.setNewValues(rs.getString("new_values"));
        a.setIpAddress(rs.getString("ip_address"));
        a.setUserAgent(rs.getString("user_agent"));
        a.setStatus(rs.getString("status"));
        a.setErrorMessage(rs.getString("error_message"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        
        String fullName = rs.getString("user_name");
        String email = rs.getString("user_email");
        if (fullName != null && email != null) {
            a.setUserName(fullName + " (" + email + ")");
        } else if (fullName != null) {
            a.setUserName(fullName);
        } else {
            a.setUserName("System");
        }
        
        return a;
    }
}

