package com.dermathologyai.dao;

import com.dermathologyai.model.UserToken;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/**
 * DAO for the user_tokens table.
 * OTP values stored here are BCrypt hashes — never plain-text.
 */
public class UserTokenDAO extends DBContext {

    private static final String SELECT_COLS =
        "SELECT id, user_id, token, purpose, attempts, expires_at, used_at FROM user_tokens";

    public boolean create(UserToken token) {
        String sql = "INSERT INTO user_tokens (user_id, token, purpose, attempts, expires_at)" +
                     " VALUES (?, ?, ?, ?, ?)";
        return executeUpdate(sql,
            token.getUserId(), token.getToken(), token.getPurpose(),
            token.getAttempts(), token.getExpiresAt()
        );
    }

    /** Looks up the active token for a user by purpose (e.g. "RESET_PASSWORD", "CHANGE_SECURITY"). */
    public UserToken findByUserIdAndPurpose(String userId, String purpose) {
        return queryOne(
            SELECT_COLS + " WHERE user_id = ? AND purpose = ?",
            UserTokenDAO::mapRow, userId, purpose
        );
    }

    public boolean deleteByUserIdAndPurpose(String userId, String purpose) {
        return executeUpdate(
            "DELETE FROM user_tokens WHERE user_id = ? AND purpose = ?", userId, purpose
        );
    }

    /** Marks a token as used (sets used_at timestamp). */
    public boolean markUsed(int tokenId) {
        return executeUpdate(
            "UPDATE user_tokens SET used_at = SYSDATETIME() WHERE id = ?", tokenId
        );
    }

    public boolean invalidateAllByUserAndPurpose(String userId, String purpose) {
        return executeUpdate(
            "UPDATE user_tokens SET used_at = SYSDATETIME() WHERE user_id = ? AND purpose = ? AND used_at IS NULL",
            userId, purpose
        );
    }

    public int incrementAttempts(int tokenId) {
        executeUpdate("UPDATE user_tokens SET attempts = attempts + 1 WHERE id = ?", tokenId);
        return queryScalar("SELECT attempts FROM user_tokens WHERE id = ?", tokenId);
    }

    private static UserToken mapRow(ResultSet rs) throws SQLException {
        UserToken t = new UserToken();
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

