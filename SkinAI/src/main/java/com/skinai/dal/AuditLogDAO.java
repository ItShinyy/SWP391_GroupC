package com.skinai.dal;

import com.skinai.model.AuditLog;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {
    private static final Logger logger = LoggerFactory.getLogger(AuditLogDAO.class);

    public AuditLog findById(String id) {
        String sql = "SELECT a.id, a.user_id, a.action, a.entity_type, a.record_id, a.old_values, a.new_values, a.ip_address, a.user_agent, a.created_at, " +
                     "u.full_name as user_name " +
                     "FROM audit_logs a " +
                     "LEFT JOIN users u ON a.user_id = u.id " +
                     "WHERE a.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding audit log by id: {}", id, e);
        }
        return null;
    }

    public List<AuditLog> findAll(int page, int pageSize) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT a.id, a.user_id, a.action, a.entity_type, a.record_id, a.old_values, a.new_values, a.ip_address, a.user_agent, a.created_at, " +
                     "u.full_name as user_name " +
                     "FROM audit_logs a " +
                     "LEFT JOIN users u ON a.user_id = u.id " +
                     "ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding all audit logs", e);
        }
        return list;
    }

    public int countAll() {
        return countAll(null, null);
    }

    public List<AuditLog> findAll(String search, String action, int page, int pageSize) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT a.id, a.user_id, a.action, a.entity_type, a.record_id, a.old_values, a.new_values, a.ip_address, a.user_agent, a.created_at, " +
                     "u.full_name as user_name " +
                     "FROM audit_logs a " +
                     "LEFT JOIN users u ON a.user_id = u.id " +
                     "WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR a.entity_type LIKE ? OR a.record_id LIKE ?)");
            String pattern = "%" + search.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (action != null && !action.trim().isEmpty()) {
            sql.append(" AND a.action = ?");
            params.add(action.trim());
        }

        sql.append(" ORDER BY a.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            int paramIndex = 1;
            for (Object param : params) {
                ps.setObject(paramIndex++, param);
            }
            ps.setInt(paramIndex++, (page - 1) * pageSize);
            ps.setInt(paramIndex, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding all audit logs with filters", e);
        }
        return list;
    }

    public int countAll(String search, String action) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_logs a LEFT JOIN users u ON a.user_id = u.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (u.full_name LIKE ? OR a.entity_type LIKE ? OR a.record_id LIKE ?)");
            String pattern = "%" + search.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (action != null && !action.trim().isEmpty()) {
            sql.append(" AND a.action = ?");
            params.add(action.trim());
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            int paramIndex = 1;
            for (Object param : params) {
                ps.setObject(paramIndex++, param);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error counting audit logs with filters", e);
        }
        return 0;
    }

    public String create(AuditLog log) {
        String sql = "INSERT INTO audit_logs (id, user_id, action, entity_type, record_id, old_values, new_values, ip_address, user_agent) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, log.getUserId());
            ps.setString(2, log.getAction());
            ps.setString(3, log.getEntityType());
            ps.setString(4, log.getRecordId());
            ps.setString(5, log.getOldValues());
            ps.setString(6, log.getNewValues());
            ps.setString(7, log.getIpAddress());
            ps.setString(8, log.getUserAgent());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating audit log", e);
        }
        return null;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
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
        if (rs.getTimestamp("created_at") != null) {
            a.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        
        // Transient field
        a.setUserName(rs.getString("user_name"));
        
        return a;
    }
}
