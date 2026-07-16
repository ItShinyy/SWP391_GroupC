package com.dermathologyai.dao;

import com.dermathologyai.model.Doctor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DoctorDAO.class);

    /**
     * Tìm thông tin bác sĩ theo ID của bác sĩ.
     * Kết hợp (JOIN) với bảng users để lấy họ tên, email, sđt và bảng clinics để lấy tên phòng khám.
     *
     * @param id ID của bác sĩ (UNIQUEIDENTIFIER)
     * @return Đối tượng Doctor chứa đầy đủ thông tin hoặc null nếu không tìm thấy
     */
    public Doctor findById(String id) {
        String sql = "SELECT d.id, d.user_id, d.clinic_id, d.specialization, d.license_number, d.bio, d.is_active, d.created_at, d.updated_at, " +
                     "u.full_name, u.email, u.phone, " +
                     "c.clinic_name, c.address as clinic_address " +
                     "FROM doctors d " +
                     "JOIN users u ON d.user_id = u.id " +
                     "JOIN clinics c ON d.clinic_id = c.id " +
                     "WHERE d.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi tìm bác sĩ theo ID: {}", id, e);
        }
        return null;
    }

    /**
     * Tìm thông tin bác sĩ theo ID của tài khoản người dùng (users.id).
     * Được gọi khi bác sĩ đăng nhập thành công để lấy thông tin chuyên môn và phòng khám.
     *
     * @param userId ID người dùng trong hệ thống
     * @return Đối tượng Doctor tương ứng hoặc null nếu người dùng này không phải là bác sĩ
     */
    public Doctor findByUserId(String userId) {
        String sql = "SELECT d.id, d.user_id, d.clinic_id, d.specialization, d.license_number, d.bio, d.is_active, d.created_at, d.updated_at, " +
                     "u.full_name, u.email, u.phone, " +
                     "c.clinic_name, c.address as clinic_address " +
                     "FROM doctors d " +
                     "JOIN users u ON d.user_id = u.id " +
                     "JOIN clinics c ON d.clinic_id = c.id " +
                     "WHERE d.user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi tìm bác sĩ theo UserId: {}", userId, e);
        }
        return null;
    }

    /**
     * Lấy danh sách các bác sĩ thuộc một phòng khám cụ thể và đang hoạt động.
     *
     * @param clinicId ID của phòng khám
     * @return Danh sách các bác sĩ (Doctor) của phòng khám đó
     */
    public List<Doctor> findByClinicId(String clinicId) {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.id, d.user_id, d.clinic_id, d.specialization, d.license_number, d.bio, d.is_active, d.created_at, d.updated_at, " +
                     "u.full_name, u.email, u.phone, " +
                     "c.clinic_name, c.address as clinic_address " +
                     "FROM doctors d " +
                     "JOIN users u ON d.user_id = u.id " +
                     "JOIN clinics c ON d.clinic_id = c.id " +
                     "WHERE d.clinic_id = ? AND d.is_active = 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clinicId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy danh sách bác sĩ theo ClinicId: {}", clinicId, e);
        }
        return list;
    }

    /**
     * Lấy toàn bộ danh sách bác sĩ trong hệ thống, sắp xếp theo họ tên.
     *
     * @return Danh sách tất cả bác sĩ
     */
    public List<Doctor> findAll() {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.id, d.user_id, d.clinic_id, d.specialization, d.license_number, d.bio, d.is_active, d.created_at, d.updated_at, " +
                     "u.full_name, u.email, u.phone, " +
                     "c.clinic_name, c.address as clinic_address " +
                     "FROM doctors d " +
                     "JOIN users u ON d.user_id = u.id " +
                     "JOIN clinics c ON d.clinic_id = c.id " +
                     "ORDER BY u.full_name";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy danh sách tất cả bác sĩ", e);
        }
        return list;
    }

    /**
     * Ánh xạ (map) một hàng kết quả từ ResultSet thành đối tượng Doctor model.
     */
    private Doctor mapRow(ResultSet rs) throws SQLException {
        Doctor d = new Doctor();
        d.setId(rs.getString("id"));
        d.setUserId(rs.getString("user_id"));
        d.setClinicId(rs.getString("clinic_id"));
        d.setSpecialization(rs.getString("specialization"));
        d.setLicenseNumber(rs.getString("license_number"));
        d.setBio(rs.getString("bio"));
        d.setActive(rs.getBoolean("is_active"));
        if (rs.getTimestamp("created_at") != null) {
            d.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            d.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        d.setFullName(rs.getString("full_name"));
        d.setEmail(rs.getString("email"));
        d.setPhone(rs.getString("phone"));
        d.setClinicName(rs.getString("clinic_name"));
        d.setClinicAddress(rs.getString("clinic_address"));
        return d;
    }
}
