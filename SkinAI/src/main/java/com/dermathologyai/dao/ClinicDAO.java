package com.dermathologyai.dao;

import com.dermathologyai.model.Clinic;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.List;

/**
 * DAO for the clinics table.
 * Lưu ý: Các cột google_place_id, latitude, longitude, specialty, rating, website
 * có thể chưa tồn tại trong DB cũ — dùng SELECT_COLS_SAFE để tránh lỗi.
 */
public class ClinicDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(ClinicDAO.class);

    /**
     * Chỉ SELECT các cột CỐT LÕI chắc chắn có trong DB (tương thích với schema gốc).
     */
    private static final String SELECT_COLS =
        "SELECT id, clinic_name, address, phone, is_active, created_at, updated_at FROM clinics";

    /**
     * SELECT đầy đủ khi DB đã được migrate (có google_place_id, latitude, longitude, specialty, rating, website).
     * Dùng khi đã chạy migration script.
     */
    private static final String SELECT_COLS_FULL =
        "SELECT id, google_place_id, clinic_name, address, phone, website," +
        " latitude, longitude, specialty, rating, is_active, created_at, updated_at FROM clinics";

    public Clinic findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", ClinicDAO::mapRow, id);
    }

    public List<Clinic> findAll() {
        return queryList(SELECT_COLS + " ORDER BY clinic_name ASC", ClinicDAO::mapRow);
    }

    public List<Clinic> findActive() {
        return queryList(
            SELECT_COLS + " WHERE is_active = 1 ORDER BY clinic_name ASC",
            ClinicDAO::mapRow
        );
    }

    public List<Clinic> findBySpecialty(String specialty) {
        return queryList(
            SELECT_COLS + " WHERE is_active = 1 ORDER BY clinic_name ASC",
            ClinicDAO::mapRow
        );
    }

    public int countAll() {
        return queryScalar("SELECT COUNT(*) FROM clinics");
    }

    public String create(Clinic c) {
        String sql = "INSERT INTO clinics (id, clinic_name, address, phone, is_active)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?)";
        return insertReturningId(sql,
            c.getClinicName(), c.getAddress(),
            c.getPhone(),
            c.isActive() ? 1 : 0
        );
    }

    public boolean update(Clinic c) {
        String sql = "UPDATE clinics SET clinic_name = ?, address = ?, phone = ?," +
                     " is_active = ?, updated_at = GETDATE() WHERE id = ?";
        return executeUpdate(sql,
            c.getClinicName(), c.getAddress(),
            c.getPhone(),
            c.isActive() ? 1 : 0,
            c.getId()
        );
    }

    public boolean deactivate(String id) {
        return executeUpdate(
            "UPDATE clinics SET is_active = 0, updated_at = GETDATE() WHERE id = ?", id
        );
    }

    /**
     * Ánh xạ ResultSet cơ bản — chỉ đọc các cột chắc chắn có trong DB.
     * Các trường optional (googlePlaceId, website, latitude...) được để null/default.
     */
    private static Clinic mapRow(ResultSet rs) throws SQLException {
        Clinic c = new Clinic();
        c.setId(rs.getString("id"));
        c.setClinicName(rs.getString("clinic_name"));
        c.setAddress(rs.getString("address"));
        c.setPhone(rs.getString("phone"));
        c.setActive(rs.getInt("is_active") == 1);
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) c.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) c.setUpdatedAt(ua.toLocalDateTime());
        // Các trường mở rộng để null — sẽ đọc sau khi chạy migration
        c.setGooglePlaceId(null);
        c.setWebsite(null);
        c.setLatitude(0);
        c.setLongitude(0);
        c.setSpecialty(null);
        c.setRating(0);
        return c;
    }
}
