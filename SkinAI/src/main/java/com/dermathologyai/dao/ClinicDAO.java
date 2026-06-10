package com.dermathologyai.dao;

import com.dermathologyai.model.Clinic;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.List;

/**
 * DAO for the clinics table.
 */
public class ClinicDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(ClinicDAO.class);

    private static final String SELECT_COLS =
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
            SELECT_COLS + " WHERE is_active = 1 ORDER BY rating DESC, clinic_name ASC",
            ClinicDAO::mapRow
        );
    }

    public List<Clinic> findBySpecialty(String specialty) {
        return queryList(
            SELECT_COLS + " WHERE is_active = 1 AND specialty LIKE ? ORDER BY rating DESC",
            ClinicDAO::mapRow, "%" + specialty + "%"
        );
    }

    public int countAll() {
        return queryScalar("SELECT COUNT(*) FROM clinics");
    }

    public String create(Clinic c) {
        String sql = "INSERT INTO clinics (id, google_place_id, clinic_name, address, phone, website," +
                     " latitude, longitude, specialty, rating, is_active)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return insertReturningId(sql,
            c.getGooglePlaceId(), c.getClinicName(), c.getAddress(),
            c.getPhone(), c.getWebsite(),
            c.getLatitude(), c.getLongitude(),
            c.getSpecialty(), c.getRating(),
            c.isActive() ? 1 : 0
        );
    }

    public boolean update(Clinic c) {
        String sql = "UPDATE clinics SET google_place_id = ?, clinic_name = ?, address = ?, phone = ?," +
                     " website = ?, latitude = ?, longitude = ?, specialty = ?, rating = ?," +
                     " is_active = ?, updated_at = GETDATE() WHERE id = ?";
        return executeUpdate(sql,
            c.getGooglePlaceId(), c.getClinicName(), c.getAddress(),
            c.getPhone(), c.getWebsite(),
            c.getLatitude(), c.getLongitude(),
            c.getSpecialty(), c.getRating(),
            c.isActive() ? 1 : 0,
            c.getId()
        );
    }

    public boolean deactivate(String id) {
        return executeUpdate(
            "UPDATE clinics SET is_active = 0, updated_at = GETDATE() WHERE id = ?", id
        );
    }

    private static Clinic mapRow(ResultSet rs) throws SQLException {
        Clinic c = new Clinic();
        c.setId(rs.getString("id"));
        c.setGooglePlaceId(rs.getString("google_place_id"));
        c.setClinicName(rs.getString("clinic_name"));
        c.setAddress(rs.getString("address"));
        c.setPhone(rs.getString("phone"));
        c.setWebsite(rs.getString("website"));
        c.setLatitude(rs.getDouble("latitude"));
        c.setLongitude(rs.getDouble("longitude"));
        c.setSpecialty(rs.getString("specialty"));
        c.setRating(rs.getDouble("rating"));
        c.setActive(rs.getInt("is_active") == 1);
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) c.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) c.setUpdatedAt(ua.toLocalDateTime());
        return c;
    }
}

