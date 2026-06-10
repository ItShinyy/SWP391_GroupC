package com.dermathologyai.dao;

import com.dermathologyai.model.PasswordResetToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;

/**
 * DAO for the password_reset_tokens table.
 * OTP values stored here are BCrypt hashes — never plain-text.
 */
public class PasswordResetTokenDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(PasswordResetTokenDAO.class);

    private static final String SELECT_COLS =
        "SELECT id, user_id, token, purpose, attempts, expires_at, used_at FROM password_reset_tokens";

    public boolean create(PasswordResetToken token) {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, purpose, attempts, expires_at)" +
                     " VALUES (?, ?, ?, ?, ?)";
        return executeUpdate(sql,
            token.getUserId(), token.getToken(), token.getPurpose(),
            token.getAttempts(), token.getExpiresAt()
        );
    }

    /** Looks up the active token for a user by purpose (e.g. "RESET_PASSWORD", "CHANGE_SECURITY"). */
    public PasswordResetToken findByUserIdAndPurpose(String userId, String purpose) {
        return queryOne(
            SELECT_COLS + " WHERE user_id = ? AND purpose = ?",
            PasswordResetTokenDAO::mapRow, userId, purpose
        );
    }

    /** Looks up a token by its stored hash value (only used in legacy paths). */
    public PasswordResetToken findByToken(String tokenHash) {
        return queryOne(
            SELECT_COLS + " WHERE token = ?",
            PasswordResetTokenDAO::mapRow, tokenHash
        );
    }

    public boolean updateAttempts(int tokenId, int attempts) {
        return executeUpdate(
            "UPDATE password_reset_tokens SET attempts = ? WHERE id = ?", attempts, tokenId
        );
    }

    public boolean deleteByUserIdAndPurpose(String userId, String purpose) {
        return executeUpdate(
            "DELETE FROM password_reset_tokens WHERE user_id = ? AND purpose = ?", userId, purpose
        );
    }

    /** Marks a token as used (sets used_at timestamp). */
    public boolean markUsed(int tokenId) {
        return executeUpdate(
            "UPDATE password_reset_tokens SET used_at = SYSDATETIME() WHERE id = ?", tokenId
        );
    }

    /**
     * Inserts a new token and returns its generated integer ID.
     * Used by the appeal flow to get the token ID for linking to account_appeals.
     */
    public int createReturningId(PasswordResetToken token) {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, purpose, attempts, expires_at)" +
                     " OUTPUT INSERTED.id" +
                     " VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, token.getUserId(), token.getToken(), token.getPurpose(),
                      token.getAttempts(), token.getExpiresAt());
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (java.sql.SQLException e) {
            java.util.logging.Logger.getLogger(PasswordResetTokenDAO.class.getName())
                .log(java.util.logging.Level.SEVERE, "createReturningId failed", e);
        }
        return -1;
    }

    private static PasswordResetToken mapRow(ResultSet rs) throws SQLException {
        PasswordResetToken t = new PasswordResetToken();
        t.setId(rs.getInt("id"));
        t.setUserId(rs.getString("user_id"));
        t.setToken(rs.getString("token"));
        t.setPurpose(rs.getString("purpose"));
        t.setAttempts(rs.getInt("attempts"));
        Timestamp ex = rs.getTimestamp("expires_at"); if (ex != null) t.setExpiresAt(ex.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("used_at"); if (ua != null) t.setUsedAt(ua.toLocalDateTime());
        return t;
    }
}

