package com.dermathologyai.dao;

import com.dermathologyai.model.Notification;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

public class NotificationDAO extends DBContext {
    private static final String SELECT_WITH_RECIPIENT =
        "SELECT n.id, n.user_id, n.event_key, n.type, n.title, n.message, n.target_url, " +
        "n.is_read, n.email_status, n.email_attempts, n.created_at, " +
        "u.email AS recipient_email, u.full_name AS recipient_name " +
        "FROM dbo.notifications n INNER JOIN dbo.users u ON u.id = n.user_id ";

    public boolean createIfAbsent(String userId, String eventKey, String type,
                                  String title, String message, String targetUrl) {
        String sql = "INSERT INTO dbo.notifications " +
            "(user_id, event_key, type, title, message, target_url, email_status) " +
            "SELECT ?, ?, ?, ?, ?, ?, 'PENDING' " +
            "WHERE NOT EXISTS (SELECT 1 FROM dbo.notifications WHERE event_key = ?)";
        return executeUpdate(sql, userId, eventKey, type, title, message, targetUrl, eventKey);
    }

    public List<Notification> findEmailCandidates(int limit) {
        String sql = SELECT_WITH_RECIPIENT +
            "WHERE n.email_attempts < 3 AND (" +
            "(n.email_status IN ('PENDING', 'FAILED') AND " +
            " (n.next_attempt_at IS NULL OR n.next_attempt_at <= SYSDATETIME())) OR " +
            "(n.email_status = 'SENDING' AND n.next_attempt_at <= SYSDATETIME())" +
            ") ORDER BY n.created_at ASC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        return queryList(sql, NotificationDAO::mapRow, limit);
    }

    public boolean claimForEmail(String notificationId) {
        String sql = "UPDATE dbo.notifications SET email_status = 'SENDING', " +
            "email_attempts = email_attempts + 1, " +
            "next_attempt_at = DATEADD(MINUTE, 10, SYSDATETIME()), last_error = NULL " +
            "WHERE id = ? AND email_attempts < 3 AND (" +
            "(email_status IN ('PENDING', 'FAILED') AND " +
            " (next_attempt_at IS NULL OR next_attempt_at <= SYSDATETIME())) OR " +
            "(email_status = 'SENDING' AND next_attempt_at <= SYSDATETIME())" +
            ")";
        return executeUpdate(sql, notificationId);
    }

    public boolean markEmailSent(String notificationId) {
        return executeUpdate("UPDATE dbo.notifications SET email_status = 'SENT', " +
            "email_sent_at = SYSDATETIME(), next_attempt_at = NULL, last_error = NULL WHERE id = ?", notificationId);
    }

    public boolean markEmailFailed(String notificationId, String error) {
        String safeError = error == null ? "Unknown email error" : error.substring(0, Math.min(error.length(), 1000));
        return executeUpdate("UPDATE dbo.notifications SET email_status = 'FAILED', " +
            "last_error = ?, next_attempt_at = DATEADD(MINUTE, 5, SYSDATETIME()) WHERE id = ?", safeError, notificationId);
    }

    public List<Notification> findByUserId(String userId) {
        return queryList(SELECT_WITH_RECIPIENT + "WHERE n.user_id = ? ORDER BY n.created_at DESC",
            NotificationDAO::mapRow, userId);
    }

    public int countUnreadByUserId(String userId) {
        return queryScalar("SELECT COUNT(*) FROM dbo.notifications WHERE user_id = ? AND is_read = 0",
            Integer.class, userId);
    }

    public boolean markRead(String notificationId, String userId) {
        return executeUpdate("UPDATE dbo.notifications SET is_read = 1 WHERE id = ? AND user_id = ?",
            notificationId, userId);
    }

    public boolean markAllRead(String userId) {
        return executeUpdate("UPDATE dbo.notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0", userId);
    }

    private static Notification mapRow(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setId(rs.getString("id"));
        notification.setUserId(rs.getString("user_id"));
        notification.setEventKey(rs.getString("event_key"));
        notification.setType(rs.getString("type"));
        notification.setTitle(rs.getString("title"));
        notification.setMessage(rs.getString("message"));
        notification.setTargetUrl(rs.getString("target_url"));
        notification.setRead(rs.getBoolean("is_read"));
        notification.setEmailStatus(rs.getString("email_status"));
        notification.setEmailAttempts(rs.getInt("email_attempts"));
        notification.setRecipientEmail(rs.getString("recipient_email"));
        notification.setRecipientName(rs.getString("recipient_name"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) notification.setCreatedAt(createdAt.toLocalDateTime());
        return notification;
    }
}
