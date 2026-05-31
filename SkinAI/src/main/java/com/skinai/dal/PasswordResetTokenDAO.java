package com.skinai.dal;

import com.skinai.model.PasswordResetToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;

public class PasswordResetTokenDAO {
    private static final Logger logger = LoggerFactory.getLogger(PasswordResetTokenDAO.class);

    public boolean create(PasswordResetToken token) {
        String sql = "INSERT INTO password_reset_tokens (user_id, token, purpose, attempts, expires_at) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.getUserId());
            ps.setString(2, token.getToken()); // This should be a hash!
            ps.setString(3, token.getPurpose());
            ps.setInt(4, token.getAttempts());
            ps.setObject(5, token.getExpiresAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error creating password reset token", e);
        }
        return false;
    }

    public PasswordResetToken findByUserIdAndPurpose(String userId, String purpose) {
        String sql = "SELECT id, user_id, token, purpose, attempts, expires_at FROM password_reset_tokens WHERE user_id = ? AND purpose = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, purpose);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PasswordResetToken t = new PasswordResetToken();
                    t.setId(rs.getInt("id"));
                    t.setUserId(rs.getString("user_id"));
                    t.setToken(rs.getString("token"));
                    t.setPurpose(rs.getString("purpose"));
                    t.setAttempts(rs.getInt("attempts"));
                    t.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
                    return t;
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding token by user id and purpose", e);
        }
        return null;
    }

    public boolean updateAttempts(int tokenId, int attempts) {
        String sql = "UPDATE password_reset_tokens SET attempts = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attempts);
            ps.setInt(2, tokenId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating attempts", e);
        }
        return false;
    }

    public PasswordResetToken findByToken(String tokenHash) {
        String sql = "SELECT id, user_id, token, purpose, attempts, expires_at FROM password_reset_tokens WHERE token = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PasswordResetToken t = new PasswordResetToken();
                    t.setId(rs.getInt("id"));
                    t.setUserId(rs.getString("user_id"));
                    t.setToken(rs.getString("token"));
                    t.setPurpose(rs.getString("purpose"));
                    t.setAttempts(rs.getInt("attempts"));
                    t.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
                    return t;
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding token", e);
        }
        return null;
    }

    public boolean deleteByUserIdAndPurpose(String userId, String purpose) {
        String sql = "DELETE FROM password_reset_tokens WHERE user_id = ? AND purpose = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, purpose);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting token", e);
        }
        return false;
    }
}
