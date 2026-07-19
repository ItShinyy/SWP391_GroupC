package com.dermathologyai.dao;

import com.dermathologyai.model.BugReport;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO (Data Access Object) xử lý lưu trữ và quản lý các báo cáo lỗi hệ thống (Bug Reports).
 * Giúp bác sĩ hoặc người dùng gửi phản hồi kỹ thuật trực tiếp tới CSDL để Admin kiểm tra.
 */
public class BugReportDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(BugReportDAO.class);

    /**
     * Tạo báo cáo lỗi mới.
     *
     * @param p Đối tượng BugReport chứa tiêu đề, mô tả, đường dẫn lỗi và thông tin người báo cáo
     * @return true nếu ghi nhận thành công vào CSDL, ngược lại là false
     */
    public boolean create(BugReport p) {
        String sql = "INSERT INTO bug_reports (user_id, title, description, url_path, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (p.getUserId() != null) {
                ps.setString(1, p.getUserId());
            } else {
                ps.setNull(1, Types.VARCHAR);
            }
            ps.setString(2, p.getTitle());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getUrlPath());
            ps.setString(5, p.getStatus() != null ? p.getStatus() : "PENDING");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error creating bug report", e);
        }
        return false;
    }

    /**
     * Lấy toàn bộ danh sách báo cáo lỗi, hỗ trợ phân trang cho giao diện quản trị Admin.
     * Thực hiện JOIN với bảng users để hiển thị thông tin người báo cáo (Reporter Name, Email).
     *
     * @param page Số trang hiện tại (1-indexed)
     * @param pageSize Số dòng dữ liệu mỗi trang
     * @return Danh sách đối tượng BugReport đã phân trang
     */
    public List<BugReport> findAll(int page, int pageSize) {
        List<BugReport> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT b.id, b.user_id, b.title, b.description, b.url_path, b.status, b.created_at, " +
                     "u.full_name AS reporter_name, u.email AS reporter_email, u.role AS reporter_role " +
                     "FROM bug_reports b " +
                     "LEFT JOIN users u ON b.user_id = u.id " +
                     "ORDER BY b.created_at DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BugReport r = new BugReport();
                    r.setId(rs.getString("id"));
                    r.setUserId(rs.getString("user_id"));
                    r.setTitle(rs.getString("title"));
                    r.setDescription(rs.getString("description"));
                    r.setUrlPath(rs.getString("url_path"));
                    r.setStatus(rs.getString("status"));
                    
                    Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) r.setCreatedAt(ca.toLocalDateTime());
                    
                    r.setReporterName(rs.getString("reporter_name"));
                    r.setReporterEmail(rs.getString("reporter_email"));
                    r.setReporterRole(rs.getString("reporter_role"));
                    
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding bug reports", e);
        }
        return list;
    }

    /**
     * Đếm tổng số báo cáo lỗi để phục vụ tính toán số trang trong Admin Dashboard.
     *
     * @return Tổng số báo cáo lỗi hiện có
     */
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM bug_reports";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting bug reports", e);
        }
        return 0;
    }

    /**
     * Cập nhật trạng thái xử lý lỗi (ví dụ từ PENDING sang RESOLVED).
     *
     * @param id ID của báo cáo lỗi
     * @param status Trạng thái mới cần chuyển đổi
     * @return true nếu cập nhật thành công, ngược lại là false
     */
    public boolean updateStatus(String id, String status) {
        String sql = "UPDATE bug_reports SET status = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating bug report status for id: {}", id, e);
        }
        return false;
    }
}
