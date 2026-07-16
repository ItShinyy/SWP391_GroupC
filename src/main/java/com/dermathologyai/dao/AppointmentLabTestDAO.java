package com.dermathologyai.dao;

import com.dermathologyai.model.AppointmentLabTest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentLabTestDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentLabTestDAO.class);

    public List<AppointmentLabTest> findByAppointmentId(String appointmentId) {
        List<AppointmentLabTest> list = new ArrayList<>();
        String sql = "SELECT id, appointment_id, test_name, status, result_summary, result_image_url, created_at, updated_at " +
                     "FROM appointment_lab_tests WHERE appointment_id = ? ORDER BY created_at ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi tìm xét nghiệm theo appointmentId: {}", appointmentId, e);
        }
        return list;
    }

    public boolean create(AppointmentLabTest test) {
        String sql = "INSERT INTO appointment_lab_tests (id, appointment_id, test_name, status, result_summary, result_image_url, created_at, updated_at) " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, test.getAppointmentId());
            ps.setString(2, test.getTestName());
            ps.setString(3, test.getStatus() != null ? test.getStatus() : "PENDING");
            ps.setString(4, test.getResultSummary());
            ps.setString(5, test.getResultImageUrl());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi thêm mới xét nghiệm cho lịch hẹn: {}", test.getAppointmentId(), e);
        }
        return false;
    }

    public boolean updateResult(String testId, String resultSummary, String resultImageUrl) {
        String sql = "UPDATE appointment_lab_tests SET status = 'COMPLETED', result_summary = ?, result_image_url = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, resultSummary);
            ps.setString(2, resultImageUrl);
            ps.setString(3, testId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật kết quả xét nghiệm: {}", testId, e);
        }
        return false;
    }

    private AppointmentLabTest mapRow(ResultSet rs) throws SQLException {
        AppointmentLabTest t = new AppointmentLabTest();
        t.setId(rs.getString("id"));
        t.setAppointmentId(rs.getString("appointment_id"));
        t.setTestName(rs.getString("test_name"));
        t.setStatus(rs.getString("status"));
        t.setResultSummary(rs.getString("result_summary"));
        t.setResultImageUrl(rs.getString("result_image_url"));
        if (rs.getTimestamp("created_at") != null) {
            t.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            t.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        return t;
    }
}
