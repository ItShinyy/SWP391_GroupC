package com.dermathologyai.dao;

import com.dermathologyai.model.Appointment;
import com.dermathologyai.model.AppointmentFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.List;
import java.util.ArrayList;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.LinkedHashMap;

/**
 * DAO for the appointments table.
 * createWithConnection() is kept for transactional use in BookingService.
 */
public class AppointmentDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(AppointmentDAO.class);

    private static final String SELECT_COLS =
        "SELECT a.id, a.request_id, a.patient_id, a.clinic_id, a.diagnosis_report_id, a.family_member_id," +
        " a.appointment_time, a.status, a.notes, a.created_at, a.updated_at," +
        " a.doctor_id, a.slot_id, a.doctor_status, c.clinic_name, du.full_name AS doctor_name," +
        " COALESCE(a.patient_name, u.full_name) AS patient_name, u.email AS patient_email, u.phone AS patient_phone," +
        " COALESCE(a.patient_gender, p.gender) AS patient_gender, COALESCE(a.patient_dob, p.dob) AS patient_dob" +
        " FROM appointments a" +
        " LEFT JOIN clinics c ON a.clinic_id = c.id" +
        " LEFT JOIN patients p ON a.patient_id = p.id" +
        " LEFT JOIN users u ON p.user_id = u.id" +
        " LEFT JOIN doctors d ON a.doctor_id = d.id" +
        " LEFT JOIN users du ON d.user_id = du.id";

    private static final String INSERT_SQL =
        "INSERT INTO appointments (id, request_id, patient_id, clinic_id, diagnosis_report_id, family_member_id," +
        " appointment_time, status, notes, patient_name, patient_dob, patient_gender, doctor_id, slot_id, doctor_status)" +
        " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    /** Doctor may act when assigned to a live appointment with this patient. */
    public boolean hasDoctorPatientRelationship(String doctorId, String patientId) {
        return queryScalar(
            "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND patient_id = ?" +
            " AND status NOT IN ('CANCELLED', 'NO_SHOW')",
            doctorId, patientId
        ) > 0;
    }

    /**
     * Doctor may view/review a screening when assigned to the appointment that carries that report.
     */
    public boolean hasDoctorAcceptedAppointmentForReport(String doctorId, String reportId) {
        return queryScalar(
            "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND diagnosis_report_id = ?" +
            " AND status NOT IN ('CANCELLED', 'NO_SHOW')",
            doctorId, reportId
        ) > 0;
    }

    /** True if patient already has a non-cancelled appointment at the exact time (UQ_appointments_patient_time). */
    public boolean existsActiveForPatientAtTime(String patientId, LocalDateTime appointmentTime) {
        if (patientId == null || appointmentTime == null) return false;
        return queryScalar(
            "SELECT COUNT(*) FROM appointments WHERE patient_id = ? AND appointment_time = ?" +
            " AND status NOT IN ('CANCELLED', 'NO_SHOW')",
            patientId, java.sql.Timestamp.valueOf(appointmentTime)
        ) > 0;
    }

    public Appointment findById(String id) {
        return queryOne(SELECT_COLS + " WHERE a.id = ?", AppointmentDAO::mapRow, id);
    }

    /**
     * Truy vấn đầy đủ thông tin 1 lịch hẹn theo ID, bao gồm thông tin bệnh nhân, bác sĩ, chẩn đoán AI.
     */
    public Appointment findByIdFull(String id) {
        String sql = "SELECT a.id, a.request_id, a.patient_id, a.clinic_id, a.diagnosis_report_id, a.appointment_time, a.status, a.notes, " +
                     "a.doctor_id, a.doctor_status, a.doctor_notes, a.created_at, a.updated_at, " +
                     "c.clinic_name, " +
                     "COALESCE(a.patient_name, u_p.full_name) AS patient_name, u_p.email AS patient_email, u_p.phone AS patient_phone, " +
                     "COALESCE(a.patient_gender, p.gender) AS patient_gender, COALESCE(a.patient_dob, p.dob) AS patient_dob, p.address AS patient_address, " +
                     "dis.disease_name, dr.confidence_score, dr.risk_level, dr.image_url, dr.heatmap_url, dr.recommendation " +
                     "FROM appointments a " +
                     "LEFT JOIN clinics c ON a.clinic_id = c.id " +
                     "LEFT JOIN patients p ON a.patient_id = p.id " +
                     "LEFT JOIN users u_p ON p.user_id = u_p.id " +
                     "LEFT JOIN diagnosis_reports dr ON a.diagnosis_report_id = dr.id " +
                     "LEFT JOIN diseases dis ON dis.id = COALESCE(dr.doctor_selected_disease_id, dr.disease_id, dr.ai_suggested_disease_id) " +
                     "WHERE a.id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowFull(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding full appointment by id: {}", id, e);
        }
        return null;
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
            a.getFamilyMemberId(),
            Timestamp.valueOf(a.getAppointmentTime()),
            a.getStatus() != null ? a.getStatus() : "CREATED",
            a.getNotes(),
            a.getPatientName(),
            toSqlDate(a.getPatientDob()),
            a.getPatientGender(),
            a.getDoctorId(),
            a.getSlotId(),
            a.getDoctorStatus() != null ? a.getDoctorStatus() : "PENDING"
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
                a.getFamilyMemberId(),
                Timestamp.valueOf(a.getAppointmentTime()),
                a.getStatus() != null ? a.getStatus() : "CREATED",
                a.getNotes(),
                a.getPatientName(),
                toSqlDate(a.getPatientDob()),
                a.getPatientGender(),
                a.getDoctorId(),
                a.getSlotId(),
                a.getDoctorStatus() != null ? a.getDoctorStatus() : "PENDING"
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

    /** Doctor check-in: CONFIRMED → CHECKED_IN and attendance VISITED. */
    public boolean checkIn(String id) {
        return executeUpdate(
            "UPDATE appointments SET status = 'CHECKED_IN', attendance_status = 'VISITED', updated_at = GETDATE()" +
            " WHERE id = ? AND status = 'CONFIRMED'",
            id
        );
    }

    /** Patient cancel of a not-yet-visited appointment. Releases schedule capacity when slot_id is set. */
    public boolean cancelForPatient(String id, String patientId) {
        Appointment existing = findById(id);
        boolean cancelled = executeUpdate(
            "UPDATE appointments SET status = 'CANCELLED', attendance_status = 'CANCELLED', updated_at = GETDATE()" +
            " WHERE id = ? AND patient_id = ? AND status IN ('CREATED', 'CONFIRMED')",
            id, patientId
        );
        if (cancelled && existing != null && existing.getSlotId() != null && !existing.getSlotId().isBlank()) {
            new DoctorScheduleDAO().decrementBookedCount(existing.getSlotId());
        }
        return cancelled;
    }

    private static Date toSqlDate(String raw) {
        if (raw == null || raw.isBlank()) return null;
        java.time.LocalDate parsed = com.dermathologyai.util.FormatUtil.parseDate(raw.trim());
        return parsed == null ? null : Date.valueOf(parsed);
    }

    private static Appointment mapRow(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getString("id"));
        a.setRequestId(rs.getString("request_id"));
        a.setPatientId(rs.getString("patient_id"));
        a.setClinicId(rs.getString("clinic_id"));
        a.setDiagnosisReportId(rs.getString("diagnosis_report_id"));
        try { a.setFamilyMemberId(rs.getString("family_member_id")); } catch (SQLException ignored) {}
        try { a.setSlotId(rs.getString("slot_id")); } catch (SQLException ignored) {}
        Timestamp at = rs.getTimestamp("appointment_time"); if (at != null) a.setAppointmentTime(at.toLocalDateTime());
        a.setStatus(rs.getString("status"));
        a.setNotes(rs.getString("notes"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("updated_at"); if (ua != null) a.setUpdatedAt(ua.toLocalDateTime());
        a.setClinicName(rs.getString("clinic_name"));
        a.setPatientName(rs.getString("patient_name"));
        a.setPatientEmail(rs.getString("patient_email"));
        a.setPatientPhone(rs.getString("patient_phone"));
        try { a.setDoctorId(rs.getString("doctor_id")); } catch (SQLException ignored) {}
        try { a.setDoctorStatus(rs.getString("doctor_status")); } catch (SQLException ignored) {}
        try { a.setDoctorName(rs.getString("doctor_name")); } catch (SQLException ignored) {}
        try {
            a.setPatientGender(rs.getString("patient_gender"));
        } catch (SQLException ignored) {}
        try {
            if (rs.getDate("patient_dob") != null) {
                a.setPatientDob(rs.getDate("patient_dob").toLocalDate()
                    .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            }
        } catch (SQLException ignored) {}
        return a;
    }

    private void applyFilter(StringBuilder sql, List<Object> params, AppointmentFilter filter) {
        if (filter != null) {
            if (filter.getKeyword() != null && !filter.getKeyword().trim().isEmpty()) {
                sql.append(" AND (a.patient_id LIKE ? OR c.clinic_name LIKE ?)");
                String keyword = "%" + filter.getKeyword().trim() + "%";
                params.add(keyword);
                params.add(keyword);
            }
            if (filter.getStatus() != null && !filter.getStatus().isEmpty()) {
                sql.append(" AND a.status = ?");
                params.add(filter.getStatus());
            }
            if (filter.getStartDate() != null) {
                sql.append(" AND CAST(a.appointment_time AS DATE) >= ?");
                params.add(java.sql.Date.valueOf(filter.getStartDate()));
            }
            if (filter.getEndDate() != null) {
                sql.append(" AND CAST(a.appointment_time AS DATE) <= ?");
                params.add(java.sql.Date.valueOf(filter.getEndDate()));
            }
        }
    }

    public List<Appointment> findAll(int page, int pageSize, AppointmentFilter filter) {
        List<Appointment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT a.*, c.clinic_name, u.full_name AS patient_name, u.email AS patient_email, u.phone AS patient_phone FROM appointments a LEFT JOIN clinics c ON a.clinic_id = c.id LEFT JOIN patients p ON a.patient_id = p.id LEFT JOIN users u ON p.user_id = u.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        applyFilter(sql, params, filter);
        
        sql.append(" ORDER BY a.appointment_time DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ps.setInt(params.size() + 1, (page - 1) * pageSize);
            ps.setInt(params.size() + 2, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding all appointments with filter", e);
        }
        return list;
    }

    public int countAll(AppointmentFilter filter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM appointments a LEFT JOIN clinics c ON a.clinic_id = c.id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        applyFilter(sql, params, filter);
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
             
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error counting all appointments with filter", e);
        }
        return 0;
    }

    public List<Appointment> findByDoctorId(String doctorId, String statusFilter, int page, int pageSize) {
        return findByDoctorId(doctorId, statusFilter, null, null, null, page, pageSize);
    }

    public List<Appointment> findByDoctorId(String doctorId, String statusFilter, String keyword, String riskFilter, String sortBy, int page, int pageSize) {
        List<Appointment> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT a.id, a.request_id, a.patient_id, a.clinic_id, a.diagnosis_report_id, a.appointment_time, a.status, a.notes, ")
          .append("a.doctor_id, a.doctor_status, a.doctor_notes, a.created_at, a.updated_at, ")
          .append("c.clinic_name, ")
          .append("COALESCE(a.patient_name, u_p.full_name) AS patient_name, u_p.email AS patient_email, u_p.phone AS patient_phone, ")
          .append("COALESCE(a.patient_gender, p.gender) AS patient_gender, COALESCE(a.patient_dob, p.dob) AS patient_dob, p.address AS patient_address, ")
          .append("dis.disease_name, dr.confidence_score, dr.risk_level, dr.image_url, dr.heatmap_url, dr.recommendation ")
          .append("FROM appointments a ")
          .append("LEFT JOIN clinics c ON a.clinic_id = c.id ")
          .append("LEFT JOIN patients p ON a.patient_id = p.id ")
          .append("LEFT JOIN users u_p ON p.user_id = u_p.id ")
          .append("LEFT JOIN diagnosis_reports dr ON a.diagnosis_report_id = dr.id ")
          .append("LEFT JOIN diseases dis ON dis.id = COALESCE(dr.doctor_selected_disease_id, dr.disease_id, dr.ai_suggested_disease_id) ")
          .append("WHERE a.doctor_id = ? ");
          
        // Khi filter là CONFIRMED (tab mặc định "Chờ khám"), bao gồm cả CHECKED_IN và IN_PROGRESS
        // để bệnh nhân đã check-in không biến mất khỏi dashboard cho đến khi ca khám hoàn tất
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            if ("CONFIRMED".equals(statusFilter)) {
                sb.append("AND a.status IN ('CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS') ");
            } else {
                sb.append("AND a.status = ? ");
            }
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append("AND (a.patient_name LIKE ? OR u_p.full_name LIKE ? OR a.notes LIKE ?) ");
        }
        if (riskFilter != null && !riskFilter.trim().isEmpty()) {
            sb.append("AND dr.risk_level = ? ");
        }
        
        // Sorting
        if ("time_asc".equalsIgnoreCase(sortBy)) {
            sb.append("ORDER BY a.appointment_time ASC ");
        } else if ("risk_desc".equalsIgnoreCase(sortBy)) {
            sb.append("ORDER BY CASE dr.risk_level WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END ASC, a.appointment_time DESC ");
        } else {
            sb.append("ORDER BY a.appointment_time DESC ");
        }
        
        sb.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        
        String sql = sb.toString();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            ps.setString(paramIndex++, doctorId);
            // Chỉ bind tham số khi filter KHÔNG phải CONFIRMED (vì CONFIRMED dùng IN clause không có ?)
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"CONFIRMED".equals(statusFilter)) {
                ps.setString(paramIndex++, statusFilter);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (riskFilter != null && !riskFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, riskFilter);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex++, pageSize);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowFull(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy danh sách lịch hẹn theo DoctorId với bộ lọc: {}", doctorId, e);
        }
        return list;
    }

    public int countByDoctorId(String doctorId, String statusFilter) {
        return countByDoctorId(doctorId, statusFilter, null, null);
    }

    public int countByDoctorId(String doctorId, String statusFilter, String keyword, String riskFilter) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT COUNT(*) ")
          .append("FROM appointments a ")
          .append("LEFT JOIN patients p ON a.patient_id = p.id ")
          .append("LEFT JOIN users u_p ON p.user_id = u_p.id ")
          .append("LEFT JOIN diagnosis_reports dr ON a.diagnosis_report_id = dr.id ")
          .append("WHERE a.doctor_id = ? ");
          
        // Khi filter là CONFIRMED (tab mặc định), đếm cả CHECKED_IN và IN_PROGRESS
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            if ("CONFIRMED".equals(statusFilter)) {
                sb.append("AND a.status IN ('CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS') ");
            } else {
                sb.append("AND a.status = ? ");
            }
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append("AND (a.patient_name LIKE ? OR u_p.full_name LIKE ? OR a.notes LIKE ?) ");
        }
        if (riskFilter != null && !riskFilter.trim().isEmpty()) {
            sb.append("AND dr.risk_level = ? ");
        }
        
        String sql = sb.toString();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            ps.setString(paramIndex++, doctorId);
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"CONFIRMED".equals(statusFilter)) {
                ps.setString(paramIndex++, statusFilter);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String searchPattern = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (riskFilter != null && !riskFilter.trim().isEmpty()) {
                ps.setString(paramIndex++, riskFilter);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi đếm số lịch hẹn theo DoctorId với bộ lọc: {}", doctorId, e);
        }
        return 0;
    }

    public boolean updateDoctorStatus(String appointmentId, String doctorStatus, String doctorNotes) {
        String sql = "UPDATE appointments SET doctor_status = ?, doctor_notes = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorStatus);
            ps.setString(2, doctorNotes);
            ps.setString(3, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật trạng thái bác sĩ duyệt: {}", appointmentId, e);
        }
        return false;
    }

    public boolean transferDoctor(String appointmentId, String newDoctorId, String transferNotes) {
        String sql = "UPDATE appointments SET doctor_id = ?, doctor_notes = NULL, notes = CONCAT(COALESCE(notes, ''), CHAR(13), CHAR(10), N'[Lý do chuyển ca]: ', ?), doctor_status = 'ACCEPTED', status = 'CONFIRMED', updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newDoctorId);
            ps.setString(2, transferNotes);
            ps.setString(3, appointmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi chuyển giao bác sĩ cho lịch hẹn: {}", appointmentId, e);
        }
        return false;
    }

    public void autoCancelExpiredAppointments(String doctorId) {
        String sql = "UPDATE appointments " +
                     "SET status = 'CANCELLED', updated_at = SYSDATETIME() " +
                     "WHERE doctor_id = ? " +
                     "  AND status = 'CONFIRMED' " +
                     "  AND appointment_time < DATEADD(HOUR, -2, SYSDATETIME()) " +
                     "  AND (doctor_notes IS NULL OR LTRIM(RTRIM(doctor_notes)) = '') " +
                     "  AND NOT EXISTS (SELECT 1 FROM appointment_lab_tests alt WHERE alt.appointment_id = appointments.id)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("Error auto-cancelling expired appointments for doctor {}", doctorId, e);
        }
    }

    public int countUniquePatientsByDoctor(String doctorId) {
        String sql = "SELECT COUNT(DISTINCT patient_id) FROM appointments WHERE doctor_id = ? AND status = 'COMPLETED'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting unique patients for doctor {}", doctorId, e);
        }
        return 0;
    }

    public double getAverageConfidenceByDoctor(String doctorId) {
        String sql = "SELECT AVG(dr.confidence_score) FROM appointments a " +
                     "JOIN diagnosis_reports dr ON a.diagnosis_report_id = dr.id " +
                     "WHERE a.doctor_id = ? AND a.status = 'COMPLETED'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) {
            logger.error("Error getting avg confidence for doctor {}", doctorId, e);
        }
        return 0;
    }

    public java.util.Map<String, Integer> getRiskDistributionByDoctor(String doctorId) {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT dr.risk_level, COUNT(*) FROM appointments a " +
                     "JOIN diagnosis_reports dr ON a.diagnosis_report_id = dr.id " +
                     "WHERE a.doctor_id = ? AND a.status = 'COMPLETED' " +
                     "GROUP BY dr.risk_level";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String rl = rs.getString(1);
                    if (rl == null) rl = "UNKNOWN";
                    map.put(rl, rs.getInt(2));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting risk distribution for doctor {}", doctorId, e);
        }
        return map;
    }

    public java.util.Map<String, Integer> getTopDiseasesByDoctor(String doctorId, int limit) {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT TOP (?) dis.disease_name, COUNT(*) FROM appointments a " +
                     "JOIN diagnosis_reports dr ON a.diagnosis_report_id = dr.id " +
                     "JOIN diseases dis ON dr.disease_id = dis.id " +
                     "WHERE a.doctor_id = ? AND a.status = 'COMPLETED' " +
                     "GROUP BY dis.disease_name " +
                     "ORDER BY COUNT(*) DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setString(2, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String dName = rs.getString(1);
                    if (dName == null) dName = "N/A";
                    map.put(dName, rs.getInt(2));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting top diseases for doctor {}", doctorId, e);
        }
        return map;
    }

    public java.util.Map<String, Integer> getAppointmentsTrendByDoctor(String doctorId) {
        java.util.Map<String, Integer> map = new java.util.LinkedHashMap<>();
        String sql = "SELECT TOP 7 CONVERT(VARCHAR(10), appointment_time, 111) AS date_str, COUNT(*) " +
                     "FROM appointments WHERE doctor_id = ? AND status IN ('CONFIRMED', 'CHECKED_IN', 'COMPLETED') " +
                     "GROUP BY CONVERT(VARCHAR(10), appointment_time, 111) " +
                     "ORDER BY date_str ASC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("date_str"), rs.getInt(2));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting appointments trend for doctor {}", doctorId, e);
        }
        return map;
    }

    public List<Appointment> findByDoctorAndDateRange(String doctorId, LocalDate startDate, LocalDate endDate) {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.id, a.request_id, a.patient_id, a.clinic_id, a.diagnosis_report_id, a.appointment_time, a.status, a.notes, " +
                     "a.doctor_id, a.doctor_status, a.doctor_notes, a.created_at, a.updated_at, " +
                     "u_p.full_name AS patient_name " +
                     "FROM appointments a " +
                     "LEFT JOIN patients p ON a.patient_id = p.id " +
                     "LEFT JOIN users u_p ON p.user_id = u_p.id " +
                     "WHERE a.doctor_id = ? " +
                     "  AND a.appointment_time >= ? " +
                     "  AND a.appointment_time < ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, doctorId);
            ps.setTimestamp(2, java.sql.Timestamp.valueOf(startDate.atStartOfDay()));
            ps.setTimestamp(3, java.sql.Timestamp.valueOf(endDate.plusDays(1).atStartOfDay()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Appointment a = new Appointment();
                    a.setId(rs.getString("id"));
                    a.setRequestId(rs.getString("request_id"));
                    a.setPatientId(rs.getString("patient_id"));
                    a.setClinicId(rs.getString("clinic_id"));
                    a.setDiagnosisReportId(rs.getString("diagnosis_report_id"));
                    
                    java.sql.Timestamp ts = rs.getTimestamp("appointment_time");
                    if (ts != null) a.setAppointmentTime(ts.toLocalDateTime());
                    
                    a.setStatus(rs.getString("status"));
                    a.setNotes(rs.getString("notes"));
                    a.setDoctorId(rs.getString("doctor_id"));
                    a.setDoctorStatus(rs.getString("doctor_status"));
                    a.setDoctorNotes(rs.getString("doctor_notes"));
                    
                    java.sql.Timestamp ca = rs.getTimestamp("created_at");
                    if (ca != null) a.setCreatedAt(ca.toLocalDateTime());
                    
                    java.sql.Timestamp ua = rs.getTimestamp("updated_at");
                    if (ua != null) a.setUpdatedAt(ua.toLocalDateTime());
                    
                    a.setPatientName(rs.getString("patient_name"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding appointments by doctor and date range", e);
        }
        return list;
    }

    private static Appointment mapRowFull(ResultSet rs) throws SQLException {
        Appointment a = mapRow(rs);
        try {
            a.setDoctorId(rs.getString("doctor_id"));
            a.setDoctorStatus(rs.getString("doctor_status"));
            a.setDoctorNotes(rs.getString("doctor_notes"));
            a.setPatientGender(rs.getString("patient_gender"));
            if (rs.getDate("patient_dob") != null) {
                a.setPatientDob(rs.getDate("patient_dob").toLocalDate()
                    .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")));
            }
            a.setPatientAddress(rs.getString("patient_address"));
            a.setDiseaseName(rs.getString("disease_name"));
            a.setConfidenceScore(rs.getDouble("confidence_score"));
            a.setRiskLevel(rs.getString("risk_level"));
            a.setImageUrl(rs.getString("image_url"));
            a.setHeatmapUrl(rs.getString("heatmap_url"));
            a.setRecommendation(rs.getString("recommendation"));
        } catch (SQLException ignored) {}
        return a;
    }
}
