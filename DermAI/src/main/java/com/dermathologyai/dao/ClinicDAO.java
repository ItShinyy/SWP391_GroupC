package com.dermathologyai.dao;

import com.dermathologyai.model.Clinic;

import java.sql.*;
import java.util.List;

/**
 * DAO for the clinics table.
 */
public class ClinicDAO extends DBContext {

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

    /** Active clinics with usable coordinates for map / locator. */
    public List<Clinic> findActiveWithLocation() {
        return queryList(
            SELECT_COLS + " WHERE is_active = 1" +
            " AND latitude IS NOT NULL AND longitude IS NOT NULL" +
            " AND NOT (latitude = 0 AND longitude = 0)" +
            " AND ABS(latitude) <= 90 AND ABS(longitude) <= 180" +
            " ORDER BY clinic_name ASC",
            ClinicDAO::mapRow
        );
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

    private static Clinic mapRow(ResultSet rs) throws SQLException {
        Clinic c = new Clinic();
        c.setId(rs.getString("id"));
        c.setGooglePlaceId(rs.getString("google_place_id"));
        c.setClinicName(rs.getString("clinic_name"));
        c.setAddress(rs.getString("address"));
        c.setPhone(rs.getString("phone"));
        c.setWebsite(rs.getString("website"));
        double lat = rs.getDouble("latitude");
        c.setLatitude(rs.wasNull() ? 0 : lat);
        double lng = rs.getDouble("longitude");
        c.setLongitude(rs.wasNull() ? 0 : lng);
        c.setSpecialty(rs.getString("specialty"));
        double rating = rs.getDouble("rating");
        c.setRating(rs.wasNull() ? 0 : rating);
        c.setActive(rs.getInt("is_active") == 1);
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) c.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) c.setUpdatedAt(ua.toLocalDateTime());
        return c;
    }
}

