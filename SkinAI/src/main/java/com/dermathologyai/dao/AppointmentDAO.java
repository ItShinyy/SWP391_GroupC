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
        "SELECT a.id, a.request_id, a.patient_id, a.family_member_id, a.clinic_id, a.diagnosis_report_id," +
        " a.appointment_time, a.status, a.attendance_status, a.notes, a.created_at, a.updated_at, " +
        " a.doctor_id, a.slot_id, a.doctor_status, a.doctor_notes, c.clinic_name" +
        " FROM appointments a LEFT JOIN clinics c ON a.clinic_id = c.id";

    private static final String INSERT_SQL =
        "INSERT INTO appointments (id, request_id, patient_id, family_member_id, clinic_id, diagnosis_report_id," +
        " appointment_time, status, attendance_status, notes, doctor_id, slot_id, doctor_status) OUTPUT INSERTED.id" +
        " VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

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
            a.getRequestId(), a.getPatientId(), a.getFamilyMemberId(), a.getClinicId(),
            a.getDiagnosisReportId(),
            Timestamp.valueOf(a.getAppointmentTime()),
            a.getStatus() != null ? a.getStatus() : "CREATED",
            a.getAttendanceStatus() != null ? a.getAttendanceStatus() : "NOT_VISITED",
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
        String sql = "INSERT INTO appointments (id, request_id, patient_id, family_member_id, clinic_id, diagnosis_report_id," +
                     " appointment_time, status, attendance_status, notes, doctor_id, slot_id, doctor_status) OUTPUT INSERTED.id" +
                     " VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            setParams(ps,
                a.getRequestId(), a.getPatientId(), a.getFamilyMemberId(), a.getClinicId(),
                a.getDiagnosisReportId(),
                Timestamp.valueOf(a.getAppointmentTime()),
                a.getStatus() != null ? a.getStatus() : "CREATED",
                a.getAttendanceStatus() != null ? a.getAttendanceStatus() : "NOT_VISITED",
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
            "UPDATE appointments SET status = ?, attendance_status = CASE ? " +
            "WHEN 'COMPLETED' THEN 'VISITED' WHEN 'NO_SHOW' THEN 'NO_SHOW' " +
            "WHEN 'CANCELLED' THEN 'CANCELLED' ELSE 'NOT_VISITED' END, " +
            "updated_at = GETDATE() WHERE id = ?", status, status, id
        );
    }

    /** Cancels an appointment and closes its unpaid payment records atomically. */
    public boolean cancelByPatientId(String appointmentId, String patientId) {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                int changed;
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE appointments SET status = 'CANCELLED', attendance_status = 'CANCELLED', updated_at = SYSDATETIME() " +
                        "WHERE id = ? AND patient_id = ? AND status IN ('CREATED', 'CONFIRMED')")) {
                    ps.setString(1, appointmentId);
                    ps.setString(2, patientId);
                    changed = ps.executeUpdate();
                }
                if (changed == 0) {
                    conn.rollback();
                    return false;
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE payments SET status = 'FAILED', updated_at = SYSDATETIME() " +
                        "WHERE status = 'PENDING' AND invoice_id IN " +
                        "(SELECT id FROM invoices WHERE appointment_id = ?)")) {
                    ps.setString(1, appointmentId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE invoices SET status = 'CANCELLED', paid_at = NULL, updated_at = SYSDATETIME() " +
                        "WHERE appointment_id = ? AND status = 'UNPAID'")) {
                    ps.setString(1, appointmentId);
                    ps.executeUpdate();
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Could not cancel appointment {}", appointmentId, e);
            return false;
        }
    }

    /**
     * Deletes cancelled appointments and, after that, every appointment older than the
     * newest {@code maxAppointments}. Child payments and invoices are deleted first.
     */
    public void purgeCancelledAndKeepNewestWithConnection(Connection conn, String patientId, int maxAppointments)
            throws SQLException {
        String sql = "DECLARE @appointmentsToDelete TABLE (id UNIQUEIDENTIFIER PRIMARY KEY); " +
            "INSERT INTO @appointmentsToDelete (id) " +
            "SELECT id FROM appointments WHERE patient_id = ? AND status = 'CANCELLED'; " +
            ";WITH ranked AS (" +
            " SELECT a.id, ROW_NUMBER() OVER (ORDER BY a.appointment_time DESC, a.created_at DESC, a.id DESC) AS row_num " +
            " FROM appointments a WHERE a.patient_id = ? " +
            " AND NOT EXISTS (SELECT 1 FROM @appointmentsToDelete d WHERE d.id = a.id)" +
            ") INSERT INTO @appointmentsToDelete (id) SELECT id FROM ranked WHERE row_num > ?; " +
            "DELETE p FROM payments p INNER JOIN invoices i ON i.id = p.invoice_id " +
            " INNER JOIN @appointmentsToDelete d ON d.id = i.appointment_id; " +
            "DELETE i FROM invoices i INNER JOIN @appointmentsToDelete d ON d.id = i.appointment_id; " +
            "DELETE f FROM feedbacks f INNER JOIN @appointmentsToDelete d ON d.id = f.appointment_id; " +
            "DELETE a FROM appointments a INNER JOIN @appointmentsToDelete d ON d.id = a.id;";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientId);
            ps.setString(2, patientId);
            ps.setInt(3, maxAppointments);
            ps.executeUpdate();
        }
    }

    public boolean updateDoctorStatus(String id, String doctorStatus, String doctorNotes) {
        return executeUpdate(
            "UPDATE appointments SET doctor_status = ?, doctor_notes = ?, updated_at = GETDATE() WHERE id = ?", 
            doctorStatus, doctorNotes, id
        );
    }

    /** Marks missed appointments only when their scheduled time has passed and the patient never attended. */
    public void markMissedAppointmentsAsNoShow(String patientId) {
        executeUpdate(
            "UPDATE appointments SET status = 'NO_SHOW', attendance_status = 'NO_SHOW', updated_at = SYSDATETIME() " +
            "WHERE patient_id = ? AND appointment_time < SYSDATETIME() " +
            "AND attendance_status = 'NOT_VISITED' AND status IN ('CREATED', 'CONFIRMED')",
            patientId
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

    /**
     * Kiểm tra xem bệnh nhân có lịch hẹn chưa hoàn thành hay không.
     * Lịch hẹn được coi là "chưa hoàn thành" khi status không phải là 'COMPLETED', 'CANCELLED', hoặc 'NO_SHOW'
     */
    public boolean hasIncompleteAppointment(String patientId) {
        String sql = "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND status NOT IN ('COMPLETED', 'CANCELLED', 'NO_SHOW')";
        Integer count = queryScalar(sql, Integer.class, patientId);
        return count != null && count > 0;
    }

    /** Checks unfinished appointments for the actual person being examined. */
    public boolean hasIncompleteAppointmentForExaminedPerson(String patientId, String familyMemberId) {
        String sql = familyMemberId == null
                ? "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND family_member_id IS NULL "
                    + "AND status NOT IN ('COMPLETED', 'CANCELLED', 'NO_SHOW')"
                : "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND family_member_id = ? "
                    + "AND status NOT IN ('COMPLETED', 'CANCELLED', 'NO_SHOW')";
        Integer count = familyMemberId == null
                ? queryScalar(sql, Integer.class, patientId)
                : queryScalar(sql, Integer.class, patientId, familyMemberId);
        return count != null && count > 0;
    }

    /**
     * Lấy lịch hẹn chưa hoàn thành đầu tiên của bệnh nhân (để hiển thị thông tin)
     */
    public Appointment findIncompleteAppointmentByPatientId(String patientId) {
        return queryOne(
            SELECT_COLS + " WHERE a.patient_id = ? AND a.status NOT IN ('COMPLETED', 'CANCELLED', 'NO_SHOW') ORDER BY a.appointment_time ASC",
            AppointmentDAO::mapRow, patientId
        );
    }

    private static Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getString("id"));
        a.setRequestId(rs.getString("request_id"));
        a.setPatientId(rs.getString("patient_id"));
        a.setFamilyMemberId(rs.getString("family_member_id"));
        a.setClinicId(rs.getString("clinic_id"));
        a.setDiagnosisReportId(rs.getString("diagnosis_report_id"));
        Timestamp at = rs.getTimestamp("appointment_time"); if (at != null) a.setAppointmentTime(at.toLocalDateTime());
        a.setStatus(rs.getString("status"));
        a.setAttendanceStatus(rs.getString("attendance_status"));
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

