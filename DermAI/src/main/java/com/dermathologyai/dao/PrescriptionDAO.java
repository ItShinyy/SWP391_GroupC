package com.dermathologyai.dao;

import com.dermathologyai.model.Prescription;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO (Data Access Object) xử lý các thao tác dữ liệu liên quan đến đơn thuốc (prescription).
 * Kết nối trực tiếp với bảng `appointment_prescriptions` trong cơ sở dữ liệu.
 */
public class PrescriptionDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(PrescriptionDAO.class);

    /**
     * Tìm danh sách các thuốc được kê cho một cuộc hẹn (lịch khám) cụ thể.
     *
     * @param appointmentId ID của cuộc hẹn
     * @return Danh sách đối tượng Prescription (Đơn thuốc) xếp theo thời gian thêm tăng dần
     */
    public List<Prescription> findByAppointmentId(String appointmentId) {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT id, appointment_id, drug_name, quantity, dosage, created_at, updated_at " +
                     "FROM appointment_prescriptions WHERE appointment_id = ? ORDER BY created_at ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, appointmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Prescription p = new Prescription();
                    p.setId(rs.getString("id"));
                    p.setAppointmentId(rs.getString("appointment_id"));
                    p.setDrugName(rs.getString("drug_name"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setDosage(rs.getString("dosage"));
                    
                    Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) p.setCreatedAt(ca.toLocalDateTime());
                    
                    Timestamp ua = rs.getTimestamp("updated_at");
                    if (ua != null) p.setUpdatedAt(ua.toLocalDateTime());
                    
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding prescriptions by appointment id: {}", appointmentId, e);
        }
        return list;
    }

    /**
     * Tìm một loại thuốc cụ thể trong đơn thuốc dựa theo ID bản ghi.
     *
     * @param id ID của bản ghi thuốc cần tìm
     * @return Đối tượng Prescription nếu tìm thấy, ngược lại là null
     */
    public Prescription findById(String id) {
        String sql = "SELECT id, appointment_id, drug_name, quantity, dosage, created_at, updated_at " +
                     "FROM appointment_prescriptions WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Prescription p = new Prescription();
                    p.setId(rs.getString("id"));
                    p.setAppointmentId(rs.getString("appointment_id"));
                    p.setDrugName(rs.getString("drug_name"));
                    p.setQuantity(rs.getInt("quantity"));
                    p.setDosage(rs.getString("dosage"));

                    Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) p.setCreatedAt(ca.toLocalDateTime());

                    Timestamp ua = rs.getTimestamp("updated_at");
                    if (ua != null) p.setUpdatedAt(ua.toLocalDateTime());

                    return p;
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding prescription by id: {}", id, e);
        }
        return null;
    }

    /**
     * Lưu thông tin một loại thuốc mới vào đơn thuốc của cuộc hẹn.
     *
     * @param p Đối tượng chứa thông tin thuốc cần thêm (tên thuốc, số lượng, liều lượng)
     * @return true nếu thêm thành công vào CSDL, ngược lại là false
     */
    public boolean create(Prescription p) {
        String sql = "INSERT INTO appointment_prescriptions (appointment_id, drug_name, quantity, dosage) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getAppointmentId());
            ps.setString(2, p.getDrugName());
            ps.setInt(3, p.getQuantity());
            ps.setString(4, p.getDosage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error creating prescription", e);
        }
        return false;
    }

    /**
     * Xóa một loại thuốc cụ thể khỏi đơn thuốc dựa theo ID bản ghi.
     *
     * @param id ID của bản ghi thuốc cần xóa
     * @return true nếu xóa thành công, ngược lại là false
     */
    public boolean delete(String id) {
        String sql = "DELETE FROM appointment_prescriptions WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting prescription by id: {}", id, e);
        }
        return false;
    }

    /**
     * Xóa toàn bộ đơn thuốc thuộc một cuộc hẹn (thường dùng khi dọn dẹp hoặc hủy lịch).
     *
     * @param appointmentId ID của cuộc hẹn
     * @return true nếu thực hiện thành công, ngược lại là false
     */
    public boolean deleteByAppointmentId(String appointmentId) {
        String sql = "DELETE FROM appointment_prescriptions WHERE appointment_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting prescriptions by appointment id: {}", appointmentId, e);
        }
        return false;
    }
}
