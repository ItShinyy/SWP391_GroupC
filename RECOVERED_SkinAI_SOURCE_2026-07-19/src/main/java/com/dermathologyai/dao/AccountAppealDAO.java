package com.dermathologyai.dao;

import com.dermathologyai.model.AccountAppeal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;

/**
 * DAO for the account_appeals table.
 * Unique constraint UX_account_appeals_pending_user prevents duplicate PENDING appeals.
 */
public class AccountAppealDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(AccountAppealDAO.class);

    /**
     * Inserts a new appeal.
     * Returns "DUPLICATE" if a PENDING appeal already exists for this user (constraint violation),
     * returns "OK" on success, "ERROR" on other failures.
     */
    public String create(AccountAppeal appeal) {
        String sql = "INSERT INTO account_appeals (id, user_id, token_id, appeal_text, status)" +
                     " VALUES (NEWID(), ?, ?, ?, 'PENDING')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps, appeal.getUserId(), appeal.getTokenId(), appeal.getAppealText());
            ps.executeUpdate();
            return "OK";
        } catch (SQLException e) {
            // SQL Server error 2627 = unique constraint violation
            if (e.getErrorCode() == 2627 || (e.getMessage() != null && e.getMessage().contains("UX_account_appeals_pending_user"))) {
                logger.warn("Duplicate appeal attempt for userId={}", appeal.getUserId());
                return "DUPLICATE";
            }
            logger.error("Failed to create appeal for userId={}", appeal.getUserId(), e);
            return "ERROR";
        }
    }

    /** Returns the pending appeal for a given user, or null if none. */
    public AccountAppeal findPendingByUserId(String userId) {
        String sql = "SELECT id, user_id, token_id, appeal_text, status, admin_note, reviewed_by, reviewed_at, created_at" +
                     " FROM account_appeals WHERE user_id = ? AND status = 'PENDING'";
        return queryOne(sql, AccountAppealDAO::mapRow, userId);
    }

    private static AccountAppeal mapRow(ResultSet rs) throws SQLException {
        AccountAppeal a = new AccountAppeal();
        a.setId(rs.getString("id"));
        a.setUserId(rs.getString("user_id"));
        int tid = rs.getInt("token_id");
        if (!rs.wasNull()) a.setTokenId(tid);
        a.setAppealText(rs.getString("appeal_text"));
        a.setStatus(rs.getString("status"));
        a.setAdminNote(rs.getString("admin_note"));
        a.setReviewedBy(rs.getString("reviewed_by"));
        Timestamp ra = rs.getTimestamp("reviewed_at"); if (ra != null) a.setReviewedAt(ra.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("created_at");  if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        return a;
    }
}
