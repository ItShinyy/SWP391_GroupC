package com.skinai.dal;

import com.skinai.model.PasswordResetToken;
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
        "SELECT id, user_id, token, purpose, attempts, expires_at FROM password_reset_tokens";

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

    private static PasswordResetToken mapRow(ResultSet rs) throws SQLException {
        PasswordResetToken t = new PasswordResetToken();
        t.setId(rs.getInt("id"));
        t.setUserId(rs.getString("user_id"));
        t.setToken(rs.getString("token"));
        t.setPurpose(rs.getString("purpose"));
        t.setAttempts(rs.getInt("attempts"));
        Timestamp ex = rs.getTimestamp("expires_at"); if (ex != null) t.setExpiresAt(ex.toLocalDateTime());
        return t;
    }
}

