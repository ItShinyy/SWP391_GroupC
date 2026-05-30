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
        String sql = "INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.getUserId());
            ps.setString(2, token.getToken());
            ps.setObject(3, token.getExpiresAt());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error creating password reset token", e);
        }
        return false;
    }

    public PasswordResetToken findByToken(String token) {
        String sql = "SELECT id, user_id, token, expires_at FROM password_reset_tokens WHERE token = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PasswordResetToken t = new PasswordResetToken();
                    t.setId(rs.getInt("id"));
                    t.setUserId(rs.getString("user_id"));
                    t.setToken(rs.getString("token"));
                    t.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
                    return t;
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding token", e);
        }
        return null;
    }

    public boolean deleteByToken(String token) {
        String sql = "DELETE FROM password_reset_tokens WHERE token = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting token", e);
        }
        return false;
    }
}
