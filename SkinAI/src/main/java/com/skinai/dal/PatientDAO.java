package com.skinai.dal;

import com.skinai.model.Patient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;

/**
 * DAO for the patients table.
 * Phone is on the users table; patients only stores profile/clinical fields.
 */
public class PatientDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(PatientDAO.class);

    private static final String SELECT_COLS =
        "SELECT id, user_id, gender, dob, address, created_at, updated_at FROM patients";

    public Patient findById(String id) {
        return queryOne(SELECT_COLS + " WHERE id = ?", PatientDAO::mapRow, id);
    }

    public Patient findByUserId(String userId) {
        return queryOne(SELECT_COLS + " WHERE user_id = ?", PatientDAO::mapRow, userId);
    }

    public String create(Patient patient) {
        String sql = "INSERT INTO patients (id, user_id, gender, dob, address)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?)";
        return insertReturningId(sql,
            patient.getUserId(),
            patient.getGender(),
            patient.getDob() != null ? Date.valueOf(patient.getDob()) : null,
            patient.getAddress()
        );
    }

    public boolean update(Patient patient) {
        String sql = "UPDATE patients SET gender = ?, dob = ?, address = ?, updated_at = GETDATE()" +
                     " WHERE id = ?";
        return executeUpdate(sql,
            patient.getGender(),
            patient.getDob() != null ? Date.valueOf(patient.getDob()) : null,
            patient.getAddress(),
            patient.getId()
        );
    }

    private static Patient mapRow(ResultSet rs) throws SQLException {
        Patient p = new Patient();
        p.setId(rs.getString("id"));
        p.setUserId(rs.getString("user_id"));
        p.setGender(rs.getString("gender"));
        Date dob = rs.getDate("dob");           if (dob  != null) p.setDob(dob.toLocalDate());
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) p.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) p.setUpdatedAt(ua.toLocalDateTime());
        p.setAddress(rs.getString("address"));
        return p;
    }
}

