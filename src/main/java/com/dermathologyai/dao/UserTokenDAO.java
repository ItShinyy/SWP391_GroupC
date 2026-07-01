package com.dermathologyai.dao;

import com.dermathologyai.model.UserToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * DAO for the user_tokens table.
 * OTP values stored here are BCrypt hashes — never plain-text.
 */
public class UserTokenDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(UserTokenDAO.class);

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

    /** Looks up a token by its stored hash value (only used in legacy paths). */
    public UserToken findByToken(String tokenHash) {
        return queryOne(
            SELECT_COLS + " WHERE token = ?",
            UserTokenDAO::mapRow, tokenHash
        );
    }

    public UserToken findByUserIdTokenAndPurpose(String userId, String token, String purpose) {
        return queryOne(
            SELECT_COLS + " WHERE user_id = ? AND token = ? AND purpose = ?",
            UserTokenDAO::mapRow, userId, token, purpose
        );
    }

    public boolean updateAttempts(int tokenId, int attempts) {
        return executeUpdate(
            "UPDATE user_tokens SET attempts = ? WHERE id = ?", attempts, tokenId
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

    public LocalDateTime findLatestTokenCreatedAt(String userId, String purpose) {
        String sql = "SELECT TOP 1 created_at FROM user_tokens " +
                     "WHERE user_id = ? AND purpose = ? AND used_at IS NULL " +
                     "ORDER BY created_at DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, purpose);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) return ts.toLocalDateTime();
                }
            }
        } catch (SQLException e) {
            logger.error("findLatestTokenCreatedAt failed", e);
        }
        return null;
    }

    public boolean invalidateAllByUserAndPurpose(String userId, String purpose) {
        return executeUpdate(
            "UPDATE user_tokens SET used_at = SYSDATETIME() WHERE user_id = ? AND purpose = ? AND used_at IS NULL", 
            userId, purpose
        );
    }

    public int incrementAttempts(int tokenId) {
        executeUpdate("UPDATE user_tokens SET attempts = attempts + 1 WHERE id = ?", tokenId);
        // Returns the updated attempts using a quick query
        return queryScalar("SELECT attempts FROM user_tokens WHERE id = ?", tokenId);
    }

    /**
     * Inserts a new token and returns its generated integer ID.
     * Used by the appeal flow to get the token ID for linking to account_appeals.
     */
    public int createReturningId(UserToken token) {
        String sql = "INSERT INTO user_tokens (user_id, token, purpose, attempts, expires_at)" +
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
            java.util.logging.Logger.getLogger(UserTokenDAO.class.getName())
                .log(java.util.logging.Level.SEVERE, "createReturningId failed", e);
        }
        return -1;
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

