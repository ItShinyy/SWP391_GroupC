package com.dermathologyai.dao;

import com.dermathologyai.model.Feedback;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

public class FeedbackDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(FeedbackDAO.class.getName());

    public String create(Feedback feedback) {
        String id = UUID.randomUUID().toString();
        String sql = "INSERT INTO feedbacks "
                + "(id, patient_id, appointment_id, rating, category, content, status, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATETIME())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, feedback.getPatientId());
            ps.setString(3, feedback.getAppointmentId());
            ps.setInt(4, feedback.getRating());
            ps.setString(5, feedback.getCategory());
            ps.setString(6, feedback.getContent());
            ps.setString(7, feedback.getStatus());
            return ps.executeUpdate() == 1 ? id : null;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Could not create feedback", e);
            return null;
        }
    }

    public Feedback findById(String id) {
        return queryOne("SELECT * FROM feedbacks WHERE id = ?", FeedbackDAO::mapRow, id);
    }

    public Feedback findByAppointmentId(String appointmentId) {
        return queryOne("SELECT * FROM feedbacks WHERE appointment_id = ?", FeedbackDAO::mapRow, appointmentId);
    }

    public List<Feedback> findByPatientId(String patientId, int page, int pageSize) {
        int offset = Math.max(0, page - 1) * pageSize;
        return queryList(
                "SELECT * FROM feedbacks WHERE patient_id = ? "
                        + "ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY",
                FeedbackDAO::mapRow, patientId, offset, pageSize);
    }

    public boolean update(Feedback feedback) {
        return executeUpdate(
                "UPDATE feedbacks SET rating = ?, category = ?, content = ? "
                        + "WHERE id = ? AND patient_id = ?",
                feedback.getRating(), feedback.getCategory(), feedback.getContent(),
                feedback.getId(), feedback.getPatientId());
    }

    public boolean updateStatus(String id, String status) {
        return executeUpdate(
                "UPDATE feedbacks SET status = ? WHERE id = ?",
                status, id);
    }

    public boolean updateReply(Feedback feedback) {
        return executeUpdate(
                "UPDATE feedbacks SET admin_reply = ?, replied_at = SYSDATETIME(), status = ? WHERE id = ?",
                feedback.getAdminReply(), feedback.getStatus(), feedback.getId());
    }

    public int countByPatientId(String patientId) {
        return queryScalar("SELECT COUNT(*) FROM feedbacks WHERE patient_id = ?", patientId);
    }

    public int countByStatus(String status) {
        return queryScalar("SELECT COUNT(*) FROM feedbacks WHERE status = ?", status);
    }

    public List<Feedback> findAllWithFilters(
            String status, String category, String searchTerm, int page, int pageSize) {
        QueryParts parts = buildFilterQuery(status, category, searchTerm);
        String sql = "SELECT f.* FROM feedbacks f WHERE 1=1 " + parts.where
                + " ORDER BY f.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        parts.params.add(Math.max(0, page - 1) * pageSize);
        parts.params.add(pageSize);

        List<Feedback> feedbacks = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, parts.params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) feedbacks.add(mapRow(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Could not load feedback list", e);
        }
        return feedbacks;
    }

    public int countAllWithFilters(String status, String category, String searchTerm) {
        QueryParts parts = buildFilterQuery(status, category, searchTerm);
        String sql = "SELECT COUNT(*) FROM feedbacks f WHERE 1=1 " + parts.where;
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bind(ps, parts.params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Could not count feedback", e);
            return 0;
        }
    }

    private static QueryParts buildFilterQuery(String status, String category, String searchTerm) {
        QueryParts parts = new QueryParts();
        if (status != null && !status.isBlank()) {
            parts.where.append(" AND f.status = ?");
            parts.params.add(status.trim());
        }
        if (category != null && !category.isBlank()) {
            parts.where.append(" AND f.category = ?");
            parts.params.add(category.trim());
        }
        if (searchTerm != null && !searchTerm.isBlank()) {
            parts.where.append(" AND f.content LIKE ?");
            parts.params.add("%" + searchTerm.trim() + "%");
        }
        return parts;
    }

    private static void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
    }

    private static Feedback mapRow(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setId(rs.getString("id"));
        feedback.setPatientId(rs.getString("patient_id"));
        feedback.setAppointmentId(rs.getString("appointment_id"));
        feedback.setRating(rs.getInt("rating"));
        feedback.setCategory(rs.getString("category"));
        feedback.setContent(rs.getString("content"));
        feedback.setStatus(rs.getString("status"));
        feedback.setAdminReply(rs.getString("admin_reply"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) feedback.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp repliedAt = rs.getTimestamp("replied_at");
        if (repliedAt != null) feedback.setRepliedAt(repliedAt.toLocalDateTime());
        return feedback;
    }

    private static final class QueryParts {
        private final StringBuilder where = new StringBuilder();
        private final List<Object> params = new ArrayList<>();
    }
}
