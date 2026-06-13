package com.dermathologyai.dao;

import com.dermathologyai.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the users table.
 * Uses DBContext helpers to eliminate per-method connection boilerplate.
 */
public class UserDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(UserDAO.class);

    // Full column list reused across all SELECT queries
    private static final String SELECT_COLS =
        "SELECT id, google_id, username, email, pending_email, phone, password_hash, full_name, role, status, " +
        "failed_login_attempts, last_failed_login_at, lock_type, lock_reason, locked_at, password_changed_at, " +
        "created_at, updated_at, last_login_at FROM users";

    // ─── Lookup methods ────────────────────────────────────────────────────────

    public User findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", UserDAO::mapRow, id);
    }

    public User findByGoogleId(String googleId) {
        return queryOne(SELECT_COLS + " WHERE google_id = ?", UserDAO::mapRow, googleId);
    }

    public User findByEmail(String email) {
        return queryOne(SELECT_COLS + " WHERE email = ?", UserDAO::mapRow, email);
    }

    public User findByUsernameOrEmail(String keyword) {
        return queryOne(
            SELECT_COLS + " WHERE email = ? OR username = ? OR phone = ?",
            UserDAO::mapRow, keyword, keyword, keyword
        );
    }
    
    // ─── Uniqueness Check Methods ──────────────────────────────────────────────

    public boolean isUsernameTaken(String username) {
        return queryScalar("SELECT COUNT(*) FROM users WHERE username = ?", username) > 0;
    }

    public boolean isEmailTaken(String email) {
        return queryScalar("SELECT COUNT(*) FROM users WHERE email = ?", email) > 0;
    }

    public boolean isPhoneTaken(String phone) {
        return queryScalar("SELECT COUNT(*) FROM users WHERE phone = ?", phone) > 0;
    }

    // ─── Paginated / filtered queries ─────────────────────────────────────────

    public List<User> findAll(String search, String role, String status, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_COLS + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, role, status);
        sql.append(" ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        return queryList(sql.toString(), UserDAO::mapRow, params.toArray());
    }

    public int countAll(String search, String role, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, role, status);
        return queryScalar(sql.toString(), params.toArray());
    }

    public int countAll() {
        return countAll(null, null, null);
    }

    public int countPatients() {
        return queryScalar("SELECT COUNT(*) FROM users WHERE role = 'PATIENT'");
    }

    public int countActivePatients() {
        return queryScalar("SELECT COUNT(*) FROM users WHERE role = 'PATIENT' AND status = 'ACTIVE'");
    }

    // ─── Mutations ─────────────────────────────────────────────────────────────

    public String create(User user) {
        String sql = "INSERT INTO users (id, google_id, username, email, pending_email, phone, password_hash, full_name, role, status, created_at, updated_at)" +
                     " OUTPUT INSERTED.id" +
                     " VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        return insertReturningId(sql,
            user.getGoogleId(),
            user.getUsername(),
            user.getEmail(),
            user.getPendingEmail(),
            user.getPhone(),
            user.getPasswordHash(),
            user.getFullName(),
            user.getRole()   != null ? user.getRole()   : "USER",
            user.getStatus() != null ? user.getStatus() : "ACTIVE"
        );
    }

    public boolean update(User user) {
        String sql = "UPDATE users SET google_id = ?, username = ?, email = ?, pending_email = ?, phone = ?, password_hash = ?," +
                     " full_name = ?, role = ?, status = ?, updated_at = GETDATE() WHERE id = ?";
        return executeUpdate(sql,
            user.getGoogleId(), user.getUsername(), user.getEmail(), user.getPendingEmail(),
            user.getPhone(), user.getPasswordHash(), user.getFullName(),
            user.getRole(), user.getStatus(), user.getId()
        );
    }

    public boolean updateStatus(String id, String status) {
        return executeUpdate(
            "UPDATE users SET status = ?, updated_at = GETDATE() WHERE id = ?", status, id
        );
    }

    public boolean updateLastLogin(String id) {
        return executeUpdate("UPDATE users SET last_login_at = GETDATE() WHERE id = ?", id);
    }

    public boolean incrementFailedLogin(String userId) {
        String sql = "UPDATE users SET failed_login_attempts = failed_login_attempts + 1, " +
                     "last_failed_login_at = SYSDATETIME(), " +
                     "status = CASE WHEN failed_login_attempts + 1 >= 5 THEN 'LOCKED' ELSE status END, " +
                     "lock_type = CASE WHEN failed_login_attempts + 1 >= 5 THEN 'BRUTE_FORCE' ELSE lock_type END, " +
                     "locked_at = CASE WHEN failed_login_attempts + 1 >= 5 THEN SYSDATETIME() ELSE locked_at END " +
                     "WHERE id = ?";
        return executeUpdate(sql, userId);
    }

    public boolean recordSuccessfulLogin(String userId) {
        String sql = "UPDATE users SET failed_login_attempts = 0, last_failed_login_at = NULL, last_login_at = SYSDATETIME() WHERE id = ?";
        return executeUpdate(sql, userId);
    }

    public boolean lockWithReason(String userId, String reason) {
        String sql = "UPDATE users SET status = 'LOCKED', lock_type = 'ADMIN', lock_reason = ?, locked_at = SYSDATETIME() WHERE id = ?";
        return executeUpdate(sql, reason, userId);
    }

    public boolean unlock(String userId) {
        String sql = "UPDATE users SET status = 'ACTIVE', failed_login_attempts = 0, lock_type = NULL, lock_reason = NULL, locked_at = NULL WHERE id = ?";
        return executeUpdate(sql, userId);
    }

    public boolean updatePassword(String userId, String hashedPassword) {
        String sql = "UPDATE users SET password_hash = ?, password_changed_at = SYSDATETIME(), " +
                     "failed_login_attempts = 0, lock_type = NULL, lock_reason = NULL, locked_at = NULL, status = 'ACTIVE' " +
                     "WHERE id = ?";
        return executeUpdate(sql, hashedPassword, userId);
    }

    // ─── Internal helpers ──────────────────────────────────────────────────────

    private static void appendFilters(StringBuilder sql, List<Object> params,
                                      String search, String role, String status) {
        if (search != null && !search.isBlank()) {
            sql.append(" AND (email LIKE ? OR username LIKE ? OR full_name LIKE ?)");
            String p = "%" + search.trim() + "%";
            params.add(p); params.add(p); params.add(p);
        }
        if (role != null && !role.isBlank()) {
            sql.append(" AND role = ?");
            params.add(role.trim());
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }
    }

    private static User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getString("id"));
        u.setGoogleId(rs.getString("google_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPendingEmail(rs.getString("pending_email"));
        u.setPhone(rs.getString("phone"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setRole(rs.getString("role"));
        u.setStatus(rs.getString("status"));
        u.setFailedLoginAttempts(rs.getInt("failed_login_attempts"));
        u.setLockType(rs.getString("lock_type"));
        u.setLockReason(rs.getString("lock_reason"));
        
        Timestamp lfa = rs.getTimestamp("last_failed_login_at"); if (lfa != null) u.setLastFailedLoginAt(lfa.toLocalDateTime());
        Timestamp lka = rs.getTimestamp("locked_at"); if (lka != null) u.setLockedAt(lka.toLocalDateTime());
        Timestamp pca = rs.getTimestamp("password_changed_at"); if (pca != null) u.setPasswordChangedAt(pca.toLocalDateTime());

        Timestamp ca = rs.getTimestamp("created_at");   if (ca != null) u.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at");   if (ua != null) u.setUpdatedAt(ua.toLocalDateTime());
        Timestamp la = rs.getTimestamp("last_login_at"); if (la != null) u.setLastLoginAt(la.toLocalDateTime());
        return u;
    }
}

