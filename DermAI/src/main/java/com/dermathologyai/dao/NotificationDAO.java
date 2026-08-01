package com.dermathologyai.dao;

import com.dermathologyai.model.Notification;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

public class NotificationDAO extends DBContext {

    public String createPending(String userId, String eventKey, String type, String title, String message, String targetUrl) {
        String sql = "INSERT INTO notifications (id, user_id, event_key, type, title, message, target_url, is_read, email_status, email_attempts)" +
            " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?, 0, 'PENDING', 0)";
        return insertReturningId(sql, userId, eventKey, type, title, message, targetUrl);
    }

    public Notification findByEventKey(String eventKey) {
        return queryOne(
            "SELECT n.id, n.user_id, n.event_key, n.type, n.title, n.message, n.target_url, n.is_read," +
            " n.email_status, n.email_attempts, n.next_attempt_at, n.email_sent_at, n.last_error, n.created_at, u.email AS user_email" +
            " FROM notifications n LEFT JOIN users u ON u.id = n.user_id WHERE n.event_key = ?",
            NotificationDAO::mapRow, eventKey
        );
    }

    public List<Notification> findPendingEmailBatch(int limit) {
        return queryList(
            "SELECT TOP (" + Math.max(1, limit) + ") n.id, n.user_id, n.event_key, n.type, n.title, n.message, n.target_url, n.is_read," +
            " n.email_status, n.email_attempts, n.next_attempt_at, n.email_sent_at, n.last_error, n.created_at, u.email AS user_email" +
            " FROM notifications n LEFT JOIN users u ON u.id = n.user_id" +
            " WHERE n.email_status = 'PENDING' AND (n.next_attempt_at IS NULL OR n.next_attempt_at <= SYSUTCDATETIME())" +
            " ORDER BY n.created_at ASC",
            NotificationDAO::mapRow
        );
    }

    public boolean markSending(String id) {
        return executeUpdate(
            "UPDATE notifications SET email_status = 'SENDING', email_attempts = email_attempts + 1 WHERE id = ? AND email_status = 'PENDING'",
            id
        );
    }

    public boolean markSent(String id) {
        return executeUpdate(
            "UPDATE notifications SET email_status = 'SENT', email_sent_at = SYSUTCDATETIME(), last_error = NULL WHERE id = ?",
            id
        );
    }

    /** Soft fail: re-queue as PENDING with backoff. */
    public boolean markFailedRetry(String id, String error) {
        String trimmed = error == null ? null : (error.length() > 1000 ? error.substring(0, 1000) : error);
        return executeUpdate(
            "UPDATE notifications SET email_status = 'PENDING', last_error = ?," +
            " next_attempt_at = DATEADD(MINUTE, 15, SYSUTCDATETIME()) WHERE id = ?",
            trimmed, id
        );
    }

    public boolean markFailedPermanent(String id, String error) {
        String trimmed = error == null ? null : (error.length() > 1000 ? error.substring(0, 1000) : error);
        return executeUpdate(
            "UPDATE notifications SET email_status = 'FAILED', last_error = ?, next_attempt_at = NULL WHERE id = ?",
            trimmed, id
        );
    }

    public List<Notification> findByUserId(String userId) {
        return queryList(
            "SELECT n.id, n.user_id, n.event_key, n.type, n.title, n.message, n.target_url, n.is_read," +
            " n.email_status, n.email_attempts, n.next_attempt_at, n.email_sent_at, n.last_error, n.created_at, u.email AS user_email" +
            " FROM notifications n LEFT JOIN users u ON u.id = n.user_id" +
            " WHERE n.user_id = ? ORDER BY n.created_at DESC",
            NotificationDAO::mapRow, userId
        );
    }

    public int countUnreadByUserId(String userId) {
        return queryScalar("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0", userId);
    }

    public boolean markRead(String notificationId, String userId) {
        return executeUpdate(
            "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?",
            notificationId, userId
        );
    }

    public boolean markAllRead(String userId) {
        return executeUpdate(
            "UPDATE notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0",
            userId
        );
    }

    private static Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getString("id"));
        n.setUserId(rs.getString("user_id"));
        n.setEventKey(rs.getString("event_key"));
        n.setType(rs.getString("type"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setTargetUrl(rs.getString("target_url"));
        n.setRead(rs.getBoolean("is_read"));
        n.setEmailStatus(rs.getString("email_status"));
        n.setEmailAttempts(rs.getInt("email_attempts"));
        Timestamp next = rs.getTimestamp("next_attempt_at");
        if (next != null) n.setNextAttemptAt(next.toLocalDateTime());
        Timestamp sent = rs.getTimestamp("email_sent_at");
        if (sent != null) n.setEmailSentAt(sent.toLocalDateTime());
        n.setLastError(rs.getString("last_error"));
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) n.setCreatedAt(created.toLocalDateTime());
        try { n.setUserEmail(rs.getString("user_email")); } catch (SQLException ignored) {}
        return n;
    }
}
