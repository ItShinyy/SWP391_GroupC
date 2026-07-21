package com.dermathologyai.dao;

import com.dermathologyai.model.IssueReport;

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

/** Data access for patient issue reports. Admin review is intentionally separate. */
public class IssueReportDAO extends DBContext {
    private static final Logger LOGGER = Logger.getLogger(IssueReportDAO.class.getName());
    private static final String SELECT_COLUMNS =
            "SELECT ir.id, ir.report_code, ir.reporter_user_id, ir.title, ir.category, " +
            "ir.description, ir.image_url, ir.status, ir.admin_response, ir.handled_by_admin_id, " +
            "ir.created_at, ir.updated_at, ir.resolved_at, " +
            "reporter.full_name AS reporter_name, reporter.email AS reporter_email " +
            "FROM dbo.issue_reports ir " +
            "INNER JOIN dbo.users reporter ON reporter.id = ir.reporter_user_id ";

    public String create(IssueReport report) {
        String id = UUID.randomUUID().toString();
        String sql = "INSERT INTO issue_reports "
                + "(id, report_code, reporter_user_id, title, category, description, image_url, status, created_at, updated_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATETIME(), SYSDATETIME())";

        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, id);
            statement.setString(2, report.getReportCode());
            statement.setString(3, report.getReporterUserId());
            statement.setString(4, report.getTitle());
            statement.setString(5, report.getCategory());
            statement.setString(6, report.getDescription());
            statement.setString(7, report.getImageUrl());
            statement.setString(8, report.getStatus());
            return statement.executeUpdate() == 1 ? id : null;
        } catch (SQLException exception) {
            LOGGER.log(Level.SEVERE, "Could not create issue report", exception);
            return null;
        }
    }

    public List<IssueReport> findAll(String status, String search) {
        StringBuilder sql = new StringBuilder(SELECT_COLUMNS).append("WHERE 1 = 1 ");
        List<Object> parameters = new ArrayList<>();
        if (status != null && !status.isBlank() && !"ALL".equals(status)) {
            sql.append("AND ir.status = ? ");
            parameters.add(status);
        }
        if (search != null && !search.isBlank()) {
            sql.append("AND (ir.report_code LIKE ? OR ir.title LIKE ? OR reporter.full_name LIKE ?) ");
            String term = "%" + search.trim() + "%";
            parameters.add(term);
            parameters.add(term);
            parameters.add(term);
        }
        sql.append("ORDER BY CASE ir.status WHEN 'PENDING' THEN 0 WHEN 'IN_PROGRESS' THEN 1 ELSE 2 END, " +
                "ir.created_at DESC");
        return queryList(sql.toString(), IssueReportDAO::mapRow, parameters.toArray());
    }

    public IssueReport findById(String id) {
        return queryOne(SELECT_COLUMNS + "WHERE ir.id = ?", IssueReportDAO::mapRow, id);
    }

    public boolean updateStatus(String id, String status, String adminResponse, String adminId) {
        String sql = "UPDATE dbo.issue_reports SET status = ?, admin_response = ?, " +
                "handled_by_admin_id = ?, updated_at = SYSDATETIME(), " +
                "resolved_at = CASE WHEN ? = 'RESOLVED' THEN SYSDATETIME() ELSE NULL END " +
                "WHERE id = ?";
        return executeUpdate(sql, status, adminResponse, adminId, status, id);
    }

    private static IssueReport mapRow(ResultSet resultSet) throws SQLException {
        IssueReport report = new IssueReport();
        report.setId(resultSet.getString("id"));
        report.setReportCode(resultSet.getString("report_code"));
        report.setReporterUserId(resultSet.getString("reporter_user_id"));
        report.setTitle(resultSet.getString("title"));
        report.setCategory(resultSet.getString("category"));
        report.setDescription(resultSet.getString("description"));
        report.setImageUrl(resultSet.getString("image_url"));
        report.setStatus(resultSet.getString("status"));
        report.setAdminResponse(resultSet.getString("admin_response"));
        report.setHandledByAdminId(resultSet.getString("handled_by_admin_id"));
        report.setReporterName(resultSet.getString("reporter_name"));
        report.setReporterEmail(resultSet.getString("reporter_email"));
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) report.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = resultSet.getTimestamp("updated_at");
        if (updatedAt != null) report.setUpdatedAt(updatedAt.toLocalDateTime());
        Timestamp resolvedAt = resultSet.getTimestamp("resolved_at");
        if (resolvedAt != null) report.setResolvedAt(resolvedAt.toLocalDateTime());
        return report;
    }
}
