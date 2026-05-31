package com.skinai.dal;

import com.skinai.model.Patient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PatientDAO {
    private static final Logger logger = LoggerFactory.getLogger(PatientDAO.class);

    public Patient findById(String id) {
        String sql = "SELECT id, user_id, gender, dob, address, created_at, updated_at " +
                     "FROM patients WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding patient by id: {}", id, e);
        }
        return null;
    }

    public Patient findByUserId(String userId) {
        String sql = "SELECT id, user_id, gender, dob, address, created_at, updated_at " +
                     "FROM patients WHERE user_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding patient by user_id: {}", userId, e);
        }
        return null;
    }

    public String create(Patient patient) {
        String sql = "INSERT INTO patients (id, user_id, gender, dob, address) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patient.getUserId());
            ps.setString(2, patient.getGender());
            if (patient.getDob() != null) {
                ps.setDate(3, Date.valueOf(patient.getDob()));
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }
            ps.setString(4, patient.getAddress());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating patient", e);
        }
        return null;
    }

    public boolean update(Patient patient) {
        String sql = "UPDATE patients SET gender = ?, dob = ?, address = ?, updated_at = GETDATE() " +
                     "WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patient.getGender());
            if (patient.getDob() != null) {
                ps.setDate(2, Date.valueOf(patient.getDob()));
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }
            ps.setString(3, patient.getAddress());
            ps.setString(4, patient.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating patient: {}", patient.getId(), e);
        }
        return false;
    }

    private Patient mapRow(ResultSet rs) throws SQLException {
        Patient p = new Patient();
        p.setId(rs.getString("id"));
        p.setUserId(rs.getString("user_id"));
        p.setGender(rs.getString("gender"));
        if (rs.getDate("dob") != null) {
            p.setDob(rs.getDate("dob").toLocalDate());
        }
        p.setAddress(rs.getString("address"));
        if (rs.getTimestamp("created_at") != null) {
            p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            p.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        return p;
    }
}
