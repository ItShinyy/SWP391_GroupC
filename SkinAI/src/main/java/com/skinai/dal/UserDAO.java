package com.skinai.dal;

import com.skinai.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private static final Logger logger = LoggerFactory.getLogger(UserDAO.class);

    public User findById(String id) {
        String sql = "SELECT id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at, last_login_at " +
                     "FROM users WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding user by id: {}", id, e);
        }
        return null;
    }

    public User findByGoogleId(String googleId) {
        String sql = "SELECT id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at, last_login_at " +
                     "FROM users WHERE google_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, googleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding user by google_id: {}", googleId, e);
        }
        return null;
    }

    public User findByEmail(String email) {
        String sql = "SELECT id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at, last_login_at " +
                     "FROM users WHERE email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding user by email: {}", email, e);
        }
        return null;
    }

    public User findByUsernameOrEmail(String keyword) {
        String sql = "SELECT id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at, last_login_at " +
                     "FROM users WHERE email = ? OR username = ? OR phone = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, keyword);
            ps.setString(2, keyword);
            ps.setString(3, keyword);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding user by keyword: {}", keyword, e);
        }
        return null;
    }

    public List<User> findAll(int page, int pageSize) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at, last_login_at " +
                     "FROM users ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
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
            logger.error("Error finding all users", e);
        }
        return list;
    }

    public int countAll() {
        return countAll(null, null, null);
    }

    public List<User> findAll(String search, String role, String status, int page, int pageSize) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at, last_login_at FROM users WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (email LIKE ? OR username LIKE ? OR full_name LIKE ?)");
            String pattern = "%" + search.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (role != null && !role.trim().isEmpty()) {
            sql.append(" AND role = ?");
            params.add(role.trim());
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }
        
        sql.append(" ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
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
            logger.error("Error finding users with filters", e);
        }
        return list;
    }

    public int countAll(String search, String role, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1");
        
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (email LIKE ? OR username LIKE ? OR full_name LIKE ?)");
            String pattern = "%" + search.trim() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        if (role != null && !role.trim().isEmpty()) {
            sql.append(" AND role = ?");
            params.add(role.trim());
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
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
            logger.error("Error counting users with filters", e);
        }
        return 0;
    }

    public int countPatients() {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'PATIENT'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting patients", e);
        }
        return 0;
    }

    public int countActivePatients() {
        String sql = "SELECT COUNT(id) FROM users WHERE role = 'PATIENT' AND status = 'ACTIVE'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting active patients", e);
        }
        return 0;
    }

    public String create(User user) {
        String sql = "INSERT INTO users (id, google_id, username, email, phone, password_hash, full_name, role, status, created_at, updated_at) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getGoogleId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getPasswordHash());
            ps.setString(6, user.getFullName());
            ps.setString(7, user.getRole() != null ? user.getRole() : "PATIENT");
            ps.setString(8, user.getStatus() != null ? user.getStatus() : "ACTIVE");
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            logger.error("Error creating user", e);
        }
        return null;
    }

    public boolean update(User user) {
        String sql = "UPDATE users SET google_id = ?, username = ?, email = ?, phone = ?, password_hash = ?, full_name = ?, role = ?, status = ?, updated_at = GETDATE() " +
                     "WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getGoogleId());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getPasswordHash());
            ps.setString(6, user.getFullName());
            ps.setString(7, user.getRole());
            ps.setString(8, user.getStatus());
            ps.setString(9, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating user: {}", user.getId(), e);
        }
        return false;
    }

    public boolean updateStatus(String id, String status) {
        String sql = "UPDATE users SET status = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating user status: {}", id, e);
        }
        return false;
    }

    public boolean updateLastLogin(String id) {
        String sql = "UPDATE users SET last_login_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating last login: {}", id, e);
        }
        return false;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getString("id"));
        user.setGoogleId(rs.getString("google_id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setFullName(rs.getString("full_name"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        if (rs.getTimestamp("created_at") != null) {
            user.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            user.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        if (rs.getTimestamp("last_login_at") != null) {
            user.setLastLoginAt(rs.getTimestamp("last_login_at").toLocalDateTime());
        }
        return user;
    }
}
