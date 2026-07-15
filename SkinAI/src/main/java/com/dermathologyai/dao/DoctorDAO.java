package com.dermathologyai.dao;

import com.dermathologyai.model.Doctor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class DoctorDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DoctorDAO.class);

    private static final String SELECT_COLS =
        "SELECT d.id, d.user_id, d.clinic_id, d.specialization, d.license_number, d.bio, d.is_active, d.created_at, d.updated_at, " +
        "u.full_name, u.email, u.phone, " +
        "c.clinic_name, c.address as clinic_address " +
        "FROM doctors d " +
        "JOIN users u ON d.user_id = u.id " +
        "JOIN clinics c ON d.clinic_id = c.id";

    /**
     * Tìm thông tin bác sĩ theo ID của bác sĩ.
     */
    public Doctor findById(String id) {
        return queryOne(SELECT_COLS + " WHERE d.id = ?", DoctorDAO::mapRow, id);
    }

    /**
     * Tìm thông tin bác sĩ theo ID của tài khoản người dùng (users.id).
     */
    public Doctor findByUserId(String userId) {
        return queryOne(SELECT_COLS + " WHERE d.user_id = ?", DoctorDAO::mapRow, userId);
    }

    /**
     * Lấy danh sách các bác sĩ thuộc một phòng khám cụ thể và đang hoạt động.
     */
    public List<Doctor> findByClinicId(String clinicId) {
        return queryList(SELECT_COLS + " WHERE d.clinic_id = ? AND d.is_active = 1", DoctorDAO::mapRow, clinicId);
    }

    /**
     * Lấy toàn bộ danh sách bác sĩ trong hệ thống, sắp xếp theo họ tên.
     */
    public List<Doctor> findAll() {
        return queryList(SELECT_COLS + " ORDER BY u.full_name", DoctorDAO::mapRow);
    }

    /**
     * Ánh xạ (map) một hàng kết quả từ ResultSet thành đối tượng Doctor model.
     */
    private static Doctor mapRow(ResultSet rs) throws SQLException {
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
