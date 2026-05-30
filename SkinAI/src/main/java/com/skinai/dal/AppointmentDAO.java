package com.skinai.dal;

import com.skinai.model.Appointment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentDAO.class);

    public Appointment findById(String id) {
        String sql = "SELECT a.id, a.patient_id, a.clinic_id, a.diagnosis_report_id, a.appointment_time, a.status, a.notes, a.created_at, a.updated_at, " +
                     "c.clinic_name " +
                     "FROM appointments a " +
                     "LEFT JOIN clinics c ON a.clinic_id = c.id " +
                     "WHERE a.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding appointment by id: {}", id, e);
        }
        return null;
    }

    public List<Appointment> findByPatientId(String patientId) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.id, a.patient_id, a.clinic_id, a.diagnosis_report_id, a.appointment_time, a.status, a.notes, a.created_at, a.updated_at, " +
                     "c.clinic_name " +
                     "FROM appointments a " +
                     "LEFT JOIN clinics c ON a.clinic_id = c.id " +
                     "WHERE a.patient_id = ? " +
                     "ORDER BY a.appointment_time DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding appointments by patientId: {}", patientId, e);
        }
        return list;
    }

    public String create(Appointment appointment) {
        String sql = "INSERT INTO appointments (id, patient_id, clinic_id, diagnosis_report_id, appointment_time, status, notes) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, appointment.getPatientId());
            ps.setString(2, appointment.getClinicId());
            ps.setString(3, appointment.getDiagnosisReportId());
            ps.setTimestamp(4, Timestamp.valueOf(appointment.getAppointmentTime()));
            ps.setString(5, appointment.getStatus() != null ? appointment.getStatus() : "CREATED");
            ps.setString(6, appointment.getNotes());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating appointment", e);
        }
        return null;
    }

    public boolean updateStatus(String id, String status) {
        String sql = "UPDATE appointments SET status = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating appointment status: {}", id, e);
        }
        return false;
    }

    private Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getString("id"));
        a.setPatientId(rs.getString("patient_id"));
        a.setClinicId(rs.getString("clinic_id"));
        a.setDiagnosisReportId(rs.getString("diagnosis_report_id"));
        if (rs.getTimestamp("appointment_time") != null) {
            a.setAppointmentTime(rs.getTimestamp("appointment_time").toLocalDateTime());
        }
        a.setStatus(rs.getString("status"));
        a.setNotes(rs.getString("notes"));
        if (rs.getTimestamp("created_at") != null) {
            a.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        if (rs.getTimestamp("updated_at") != null) {
            a.setUpdatedAt(rs.getTimestamp("updated_at").toLocalDateTime());
        }
        
        // Transient fields
        a.setClinicName(rs.getString("clinic_name"));
        
        return a;
    }
}
