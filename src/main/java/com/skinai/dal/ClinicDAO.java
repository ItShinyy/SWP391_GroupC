package com.skinai.dal;

import com.skinai.model.Clinic;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ClinicDAO {
    private static final Logger logger = LoggerFactory.getLogger(ClinicDAO.class);

    public Clinic findById(String id) {
        String sql = "SELECT id, google_place_id, clinic_name, address, phone, website, latitude, longitude, specialty, rating, is_active, created_at, updated_at " +
                     "FROM clinics WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding clinic by id: {}", id, e);
        }
        return null;
    }

    public List<Clinic> findAll() {
        List<Clinic> list = new ArrayList<>();
        String sql = "SELECT id, google_place_id, clinic_name, address, phone, website, latitude, longitude, specialty, rating, is_active, created_at, updated_at " +
                     "FROM clinics ORDER BY clinic_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.error("Error finding all clinics", e);
        }
        return list;
    }

    public List<Clinic> findActive() {
        List<Clinic> list = new ArrayList<>();
        String sql = "SELECT id, google_place_id, clinic_name, address, phone, website, latitude, longitude, specialty, rating, is_active, created_at, updated_at " +
                     "FROM clinics WHERE is_active = 1 ORDER BY rating DESC, clinic_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.error("Error finding active clinics", e);
        }
        return list;
    }

    public List<Clinic> findBySpecialty(String specialty) {
        List<Clinic> list = new ArrayList<>();
        String sql = "SELECT id, google_place_id, clinic_name, address, phone, website, latitude, longitude, specialty, rating, is_active, created_at, updated_at " +
                     "FROM clinics WHERE is_active = 1 AND specialty LIKE ? ORDER BY rating DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + specialty + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding clinics by specialty: {}", specialty, e);
        }
        return list;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM clinics";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting clinics", e);
        }
        return 0;
    }

    public String create(Clinic clinic) {
        String sql = "INSERT INTO clinics (id, google_place_id, clinic_name, address, phone, website, latitude, longitude, specialty, rating, is_active) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clinic.getGooglePlaceId());
            ps.setString(2, clinic.getClinicName());
            ps.setString(3, clinic.getAddress());
            ps.setString(4, clinic.getPhone());
            ps.setString(5, clinic.getWebsite());
            ps.setDouble(6, clinic.getLatitude());
            ps.setDouble(7, clinic.getLongitude());
            ps.setString(8, clinic.getSpecialty());
            ps.setDouble(9, clinic.getRating());
            ps.setInt(10, clinic.isActive() ? 1 : 0);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating clinic", e);
        }
        return null;
    }

    public boolean update(Clinic clinic) {
        String sql = "UPDATE clinics SET google_place_id = ?, clinic_name = ?, address = ?, phone = ?, website = ?, " +
                     "latitude = ?, longitude = ?, specialty = ?, rating = ?, is_active = ?, updated_at = GETDATE() " +
                     "WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, clinic.getGooglePlaceId());
            ps.setString(2, clinic.getClinicName());
            ps.setString(3, clinic.getAddress());
            ps.setString(4, clinic.getPhone());
            ps.setString(5, clinic.getWebsite());
            ps.setDouble(6, clinic.getLatitude());
            ps.setDouble(7, clinic.getLongitude());
            ps.setString(8, clinic.getSpecialty());
            ps.setDouble(9, clinic.getRating());
            ps.setInt(10, clinic.isActive() ? 1 : 0);
            ps.setString(11, clinic.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating clinic: {}", clinic.getId(), e);
        }
        return false;
    }

    public boolean deactivate(String id) {
        String sql = "UPDATE clinics SET is_active = 0, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deactivating clinic: {}", id, e);
        }
        return false;
    }

    private Clinic mapRow(ResultSet rs) throws SQLException {
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
        if (rs.getTimestamp("created_at") != null) {
            c.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            c.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        return c;
    }
}
