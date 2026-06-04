package com.skinai.dal;

import com.skinai.model.Appointment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.List;

/**
 * DAO for the appointments table.
 * createWithConnection() is kept for transactional use in BookingService.
 */
public class AppointmentDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentDAO.class);

    private static final String SELECT_COLS =
        "SELECT a.id, a.request_id, a.patient_id, a.clinic_id, a.diagnosis_report_id," +
        " a.appointment_time, a.status, a.notes, a.created_at, a.updated_at, c.clinic_name" +
        " FROM appointments a LEFT JOIN clinics c ON a.clinic_id = c.id";

    private static final String INSERT_SQL =
        "INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id," +
        " appointment_time, status, notes) OUTPUT INSERTED.id" +
        " VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?)";

    public Appointment findById(String id) {
        return queryOne(SELECT_COLS + " WHERE a.id = ?", AppointmentDAO::mapRow, id);
    }

    public List<Appointment> findByPatientId(String patientId) {
        return queryList(
            SELECT_COLS + " WHERE a.patient_id = ? ORDER BY a.appointment_time DESC",
            AppointmentDAO::mapRow, patientId
        );
    }

    /** Standard insert; acquires its own connection from the pool. */
    public String create(Appointment a) {
        return insertReturningId(INSERT_SQL,
            a.getRequestId(), a.getPatientId(), a.getClinicId(),
            a.getDiagnosisReportId(),
            Timestamp.valueOf(a.getAppointmentTime()),
            a.getStatus() != null ? a.getStatus() : "CREATED",
            a.getNotes()
        );
    }

    /**
     * Transactional insert — uses the caller-supplied connection.
     * The caller is responsible for commit/rollback.
     */
    public String createWithConnection(Connection conn, Appointment a) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL)) {
            setParams(ps,
                a.getRequestId(), a.getPatientId(), a.getClinicId(),
                a.getDiagnosisReportId(),
                Timestamp.valueOf(a.getAppointmentTime()),
                a.getStatus() != null ? a.getStatus() : "CREATED",
                a.getNotes()
            );
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    public boolean updateStatus(String id, String status) {
        return executeUpdate(
            "UPDATE appointments SET status = ?, updated_at = GETDATE() WHERE id = ?", status, id
        );
    }

    private static Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getString("id"));
        a.setRequestId(rs.getString("request_id"));
        a.setPatientId(rs.getString("patient_id"));
        a.setClinicId(rs.getString("clinic_id"));
        a.setDiagnosisReportId(rs.getString("diagnosis_report_id"));
        Timestamp at = rs.getTimestamp("appointment_time"); if (at != null) a.setAppointmentTime(at.toLocalDateTime());
        a.setStatus(rs.getString("status"));
        a.setNotes(rs.getString("notes"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) a.setUpdatedAt(ua.toLocalDateTime());
        a.setClinicName(rs.getString("clinic_name"));
        return a;
    }
}

