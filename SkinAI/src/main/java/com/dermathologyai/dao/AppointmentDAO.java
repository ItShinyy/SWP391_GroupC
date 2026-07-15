package com.dermathologyai.dao;

import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.AppointmentFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;

/**
 * DAO for the appointments table.
 * createWithConnection() is kept for transactional use in BookingService.
 */
public class AppointmentDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentDAO.class);

    private static final String SELECT_COLS =
        "SELECT a.id, a.request_id, a.patient_id, a.clinic_id, a.diagnosis_report_id," +
        " a.appointment_time, a.status, a.notes, a.created_at, a.updated_at, " +
        " a.doctor_id, a.slot_id, a.doctor_status, a.doctor_notes, c.clinic_name" +
        " FROM appointments a LEFT JOIN clinics c ON a.clinic_id = c.id";

    private static final String INSERT_SQL =
        "INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id," +
        " appointment_time, status, notes, doctor_id, slot_id, doctor_status) OUTPUT INSERTED.id" +
        " VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

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
            a.getNotes(),
            a.getDoctorId(),
            a.getSlotId()
        );
    }

    /**
     * Transactional insert — uses the caller-supplied connection.
     * The caller is responsible for commit/rollback.
     */
    public String createWithConnection(Connection conn, Appointment a) throws SQLException {
        String sql = "INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id," +
                     " appointment_time, status, notes, doctor_id, slot_id, doctor_status) OUTPUT INSERTED.id" +
                     " VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps,
                a.getRequestId(), a.getPatientId(), a.getClinicId(),
                a.getDiagnosisReportId(),
                Timestamp.valueOf(a.getAppointmentTime()),
                a.getStatus() != null ? a.getStatus() : "CREATED",
                a.getNotes(),
                a.getDoctorId(),
                a.getSlotId()
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

    public boolean updateDoctorStatus(String id, String doctorStatus, String doctorNotes) {
        return executeUpdate(
            "UPDATE appointments SET doctor_status = ?, doctor_notes = ?, updated_at = GETDATE() WHERE id = ?", 
            doctorStatus, doctorNotes, id
        );
    }

    /**
     * Find all appointments with pagination and filtering for admin
     */
    public List<Appointment> findAll(int page, int pageSize, AppointmentFilter filter) {
        StringBuilder sql = new StringBuilder(SELECT_COLS);
        List<Object> params = new ArrayList<>();
        
        // Add WHERE clause if filter is provided
        if (filter != null) {
            boolean hasWhere = false;
            
            if (filter.getKeyword() != null && !filter.getKeyword().trim().isEmpty()) {
                sql.append(" WHERE (c.clinic_name LIKE ? OR a.notes LIKE ?)");
                params.add("%" + filter.getKeyword() + "%");
                params.add("%" + filter.getKeyword() + "%");
                hasWhere = true;
            }
            
            if (filter.getStatus() != null && !filter.getStatus().isEmpty()) {
                sql.append(hasWhere ? " AND" : " WHERE").append(" a.status = ?");
                params.add(filter.getStatus());
                hasWhere = true;
            }
            
            if (filter.getStartDate() != null) {
                sql.append(hasWhere ? " AND" : " WHERE").append(" DATE(a.appointment_time) >= ?");
                params.add(Date.valueOf(filter.getStartDate()));
                hasWhere = true;
            }
            
            if (filter.getEndDate() != null) {
                sql.append(hasWhere ? " AND" : " WHERE").append(" DATE(a.appointment_time) <= ?");
                params.add(Date.valueOf(filter.getEndDate()));
            }
        }
        
        sql.append(" ORDER BY a.appointment_time DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        
        return queryList(sql.toString(), AppointmentDAO::mapRow, params.toArray());
    }

    /**
     * Count all appointments with filtering for admin
     */
    public int countAll(AppointmentFilter filter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM appointments a LEFT JOIN clinics c ON a.clinic_id = c.id");
        List<Object> params = new ArrayList<>();
        
        // Add WHERE clause if filter is provided
        if (filter != null) {
            boolean hasWhere = false;
            
            if (filter.getKeyword() != null && !filter.getKeyword().trim().isEmpty()) {
                sql.append(" WHERE (c.clinic_name LIKE ? OR a.notes LIKE ?)");
                params.add("%" + filter.getKeyword() + "%");
                params.add("%" + filter.getKeyword() + "%");
                hasWhere = true;
            }
            
            if (filter.getStatus() != null && !filter.getStatus().isEmpty()) {
                sql.append(hasWhere ? " AND" : " WHERE").append(" a.status = ?");
                params.add(filter.getStatus());
                hasWhere = true;
            }
            
            if (filter.getStartDate() != null) {
                sql.append(hasWhere ? " AND" : " WHERE").append(" DATE(a.appointment_time) >= ?");
                params.add(Date.valueOf(filter.getStartDate()));
                hasWhere = true;
            }
            
            if (filter.getEndDate() != null) {
                sql.append(hasWhere ? " AND" : " WHERE").append(" DATE(a.appointment_time) <= ?");
                params.add(Date.valueOf(filter.getEndDate()));
            }
        }
        
        return queryScalar(sql.toString(), Integer.class, params.toArray());
    }

    /**
     * Find appointments by doctor ID with doctor_status filter and pagination.
     * Uses a.doctor_id column directly (correct approach).
     */
    public List<Appointment> findByDoctorId(String doctorId, String statusFilter, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_COLS + " WHERE a.doctor_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(doctorId);
        
        if (statusFilter != null && !statusFilter.isEmpty()) {
            // Lọc theo doctor_status (PENDING, ACCEPTED, REJECTED) thay vì status tổng
            sql.append(" AND a.doctor_status = ?");
            params.add(statusFilter);
        }
        
        sql.append(" ORDER BY a.appointment_time DESC");
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        
        return queryList(sql.toString(), AppointmentDAO::mapRow, params.toArray());
    }

    /**
     * Count appointments by doctor ID with doctor_status filter.
     * Uses a.doctor_id column directly (correct approach).
     */
    public int countByDoctorId(String doctorId, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM appointments a WHERE a.doctor_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(doctorId);
        
        if (statusFilter != null && !statusFilter.isEmpty()) {
            // Lọc theo doctor_status (PENDING, ACCEPTED, REJECTED) thay vì status tổng
            sql.append(" AND a.doctor_status = ?");
            params.add(statusFilter);
        }
        
        return queryScalar(sql.toString(), Integer.class, params.toArray());
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
        
        // New columns
        a.setDoctorId(rs.getString("doctor_id"));
        a.setSlotId(rs.getString("slot_id"));
        a.setDoctorStatus(rs.getString("doctor_status"));
        a.setDoctorNotes(rs.getString("doctor_notes"));
        a.setClinicName(rs.getString("clinic_name"));
        return a;
    }
}

