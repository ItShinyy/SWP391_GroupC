package com.dermathologyai.dao;

import com.dermathologyai.model.DiagnosisReport;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * DAO for the diagnosis_reports table.
 * JOINs diseases, patients, and users for display-ready transient fields.
 */
public class DiagnosisReportDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DiagnosisReportDAO.class);

    public static class ReportFilter {
        public String search;
        public String riskLevel;
        public String startDate;
        public String endDate;
        public String doctorId;
        public String diseaseId;
    }

    private static final String SELECT_COLS =
        "SELECT dr.id, dr.patient_id, dr.disease_id, dr.clinic_id, dr.image_url, dr.heatmap_url," +
        " dr.confidence_score, dr.risk_level, dr.recommendation, dr.model_version, dr.created_at," +
        " dr.ai_screening_attempt_id, dr.input_image_object_key, dr.eigencam_object_key," +
        " dr.ai_suggested_disease_id, dr.doctor_review_status," +
        " dr.reviewed_by_doctor_id, dr.reviewed_at, dr.doctor_selected_disease_id," +
        " dr.override_reason, dr.doctor_note, dr.patient_guidance, dr.patient_visibility_status," +
        " d.disease_name, u.full_name AS patient_name, u.email AS patient_email, u.phone AS patient_phone" +
        " FROM diagnosis_reports dr" +
        " LEFT JOIN diseases d ON d.id = COALESCE(dr.doctor_selected_disease_id, dr.disease_id, dr.ai_suggested_disease_id)" +
        " LEFT JOIN patients p ON dr.patient_id = p.id" +
        " LEFT JOIN users u ON p.user_id = u.id";

    // ─── Lookups ───────────────────────────────────────────────────────────────

    public DiagnosisReport findById(String id) {
        return queryOne(SELECT_COLS + " WHERE dr.id = ?", DiagnosisReportDAO::mapRow, id);
    }

    public List<DiagnosisReport> findByPatientId(String patientId, int page, int pageSize) {
        return queryList(
            SELECT_COLS + " WHERE dr.patient_id = ?" +
            " ORDER BY dr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY",
            DiagnosisReportDAO::mapRow, patientId, (page - 1) * pageSize, pageSize
        );
    }

    public List<DiagnosisReport> findVisibleByPatientId(String patientId, int page, int pageSize) {
        return queryList(
            SELECT_COLS + " WHERE dr.patient_id = ? AND dr.patient_visibility_status = 'VISIBLE'" +
            " AND dr.doctor_review_status <> 'PENDING_DOCTOR_REVIEW'" +
            " ORDER BY dr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY",
            DiagnosisReportDAO::mapRow, patientId, (page - 1) * pageSize, pageSize
        );
    }

    public int countByPatientId(String patientId) {
        return queryScalar(
            "SELECT COUNT(*) FROM diagnosis_reports WHERE patient_id = ?", patientId
        );
    }

    public int countVisibleByPatientId(String patientId) {
        return queryScalar(
            "SELECT COUNT(*) FROM diagnosis_reports WHERE patient_id = ? AND patient_visibility_status = 'VISIBLE'" +
            " AND doctor_review_status <> 'PENDING_DOCTOR_REVIEW'", patientId
        );
    }

    // ─── Filtered / paginated queries ─────────────────────────────────────────

    // ─── Filtered / paginated queries ─────────────────────────────────────────

    public List<DiagnosisReport> findAll(String search, String riskLevel, String sort,
                                         int page, int pageSize) {
        ReportFilter f = new ReportFilter();
        f.search = search;
        f.riskLevel = riskLevel;
        return findAll(f, sort, page, pageSize);
    }
    
    public List<DiagnosisReport> findAll(ReportFilter f, String sort, int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_COLS + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, f);

        String order = "precision".equals(sort) ? "dr.confidence_score DESC" : "dr.created_at DESC";
        sql.append(" ORDER BY ").append(order).append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        return queryList(sql.toString(), DiagnosisReportDAO::mapRow, params.toArray());
    }

    /** No-filter overload for simple pagination. */
    public List<DiagnosisReport> findAll(int page, int pageSize) {
        return findAll(null, null, null, page, pageSize);
    }

    public int countAll(String search, String riskLevel) {
        ReportFilter f = new ReportFilter();
        f.search = search;
        f.riskLevel = riskLevel;
        return countAll(f);
    }
    
    public int countAll(ReportFilter f) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM diagnosis_reports dr" +
            " LEFT JOIN patients p ON dr.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id" +
            " LEFT JOIN diseases d ON dr.disease_id = d.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (f != null) appendFilters(sql, params, f);
        return queryScalar(sql.toString(), params.toArray());
    }

    public int countAll() {
        return countAll((ReportFilter) null);
    }

    // ─── Dashboard analytics ───────────────────────────────────────────────────

    // ─── Dashboard analytics ───────────────────────────────────────────────────

    public Map<String, Integer> getRiskLevelDistribution() {
        return getRiskLevelDistribution(null);
    }

    public Map<String, Integer> getRiskLevelDistribution(ReportFilter f) {
        Map<String, Integer> map = new HashMap<>();
        StringBuilder sql = new StringBuilder(
            "SELECT COALESCE(dr.risk_level, 'PENDING') AS risk_level, COUNT(*) AS cnt" +
            " FROM diagnosis_reports dr" +
            " LEFT JOIN patients p ON dr.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id" +
            " LEFT JOIN diseases d ON dr.disease_id = d.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (f != null) appendFilters(sql, params, f);
        sql.append(" GROUP BY dr.risk_level");

        queryList(sql.toString(), rs -> { map.put(rs.getString("risk_level"), rs.getInt("cnt")); return null; }, params.toArray());
        return map;
    }

    public Map<String, Integer> getTopDiseases(int limit) {
        return getTopDiseases(limit, null);
    }

    public Map<String, Integer> getTopDiseases(int limit, ReportFilter f) {
        Map<String, Integer> map = new LinkedHashMap<>();
        StringBuilder sql = new StringBuilder(
            "SELECT TOP " + limit + " d.disease_name, COUNT(*) AS cnt" +
            " FROM diagnosis_reports dr" +
            " LEFT JOIN patients p ON dr.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id" +
            " JOIN diseases d ON dr.disease_id = d.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (f != null) appendFilters(sql, params, f);
        sql.append(" GROUP BY d.disease_name ORDER BY cnt DESC, d.disease_name ASC");

        queryList(sql.toString(), rs -> { map.put(rs.getString("disease_name"), rs.getInt("cnt")); return null; }, params.toArray());
        return map;
    }

    public Map<String, Integer> getScansTrend() {
        return getScansTrend(null);
    }

    public Map<String, Integer> getScansTrend(ReportFilter f) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        Map<String, Integer> map = new LinkedHashMap<>();
        for (int i = 29; i >= 0; i--) map.put(today.minusDays(i).format(fmt), 0);

        StringBuilder sql = new StringBuilder(
            "SELECT CAST(dr.created_at AS DATE) AS scan_date, COUNT(*) AS cnt" +
            " FROM diagnosis_reports dr" +
            " LEFT JOIN patients p ON dr.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id" +
            " LEFT JOIN diseases d ON dr.disease_id = d.id" +
            " WHERE dr.created_at >= DATEADD(day, -30, GETDATE())"
        );
        List<Object> params = new ArrayList<>();
        if (f != null) appendFilters(sql, params, f);
        sql.append(" GROUP BY CAST(dr.created_at AS DATE) ORDER BY scan_date ASC");

        queryList(sql.toString(), rs -> {
            String date = rs.getString("scan_date");
            if (map.containsKey(date)) map.put(date, rs.getInt("cnt"));
            return null;
        }, params.toArray());
        return map;
    }

    public double getAverageConfidenceScore() {
        return getAverageConfidenceScore(null);
    }

    public double getAverageConfidenceScore(ReportFilter f) {
        StringBuilder sql = new StringBuilder(
            "SELECT COALESCE(AVG(dr.confidence_score), 0.0) FROM diagnosis_reports dr" +
            " LEFT JOIN patients p ON dr.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id" +
            " LEFT JOIN diseases d ON dr.disease_id = d.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (f != null) appendFilters(sql, params, f);

        try (Connection conn = getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            Object[] arr = params.toArray();
            for (int i = 0; i < arr.length; i++) ps.setObject(i + 1, arr[i]);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0.0;
            }
        } catch (java.sql.SQLException e) {
            logger.error("getAverageConfidenceScore failed", e);
            return 0.0;
        }
    }


    // ─── Mutations ─────────────────────────────────────────────────────────────

    public String createScreeningReport(DiagnosisReport r) {
        if (r.getId() == null || r.getId().isBlank()) {
            throw new IllegalArgumentException("Screening reports require a pre-generated identifier.");
        }
        String sql = "INSERT INTO diagnosis_reports" +
            " (id, patient_id, disease_id, clinic_id, image_url, heatmap_url, confidence_score, risk_level," +
            " recommendation, model_version, ai_screening_attempt_id, input_image_object_key, eigencam_object_key," +
            " ai_suggested_disease_id, doctor_review_status, patient_visibility_status)" +
            " OUTPUT INSERTED.id VALUES (?, ?, ?, ?, NULL, NULL, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_DOCTOR_REVIEW', 'HIDDEN')";
        return insertReturningId(sql,
            r.getId(), r.getPatientId(), r.getDiseaseId(), r.getClinicId(), r.getConfidenceScore(), r.getRiskLevel(),
            r.getRecommendation(), r.getModelVersion(), r.getAiScreeningAttemptId(), r.getInputImageObjectKey(),
            r.getEigencamObjectKey(), r.getAiSuggestedDiseaseId()
        );
    }

    public boolean deleteUnreviewedScreeningReport(String reportId) {
        return executeUpdate("DELETE FROM diagnosis_reports WHERE id = ? AND doctor_review_status = 'PENDING_DOCTOR_REVIEW'", reportId);
    }

    public boolean applyDoctorReview(String reportId, String doctorId, String status, String selectedDiseaseId,
                                     String overrideReason, String doctorNote, String patientGuidance, boolean visibleToPatient) {
        String sql = "UPDATE diagnosis_reports SET doctor_review_status = ?, reviewed_by_doctor_id = ?," +
            " reviewed_at = SYSDATETIME(), doctor_selected_disease_id = ?, override_reason = ?," +
            " doctor_note = ?, patient_guidance = ?, patient_visibility_status = ?" +
            " WHERE id = ? AND doctor_review_status = 'PENDING_DOCTOR_REVIEW'";
        return executeUpdate(sql, status, doctorId, selectedDiseaseId, overrideReason, doctorNote, patientGuidance,
            visibleToPatient ? "VISIBLE" : "HIDDEN", reportId);
    }

    // ─── Internal helpers ──────────────────────────────────────────────────────

    private static void appendFilters(StringBuilder sql, List<Object> params, String search, String riskLevel) {
        ReportFilter f = new ReportFilter();
        f.search = search;
        f.riskLevel = riskLevel;
        appendFilters(sql, params, f);
    }

    private static void appendFilters(StringBuilder sql, List<Object> params, ReportFilter f) {
        if (f == null) return;
        if (f.search != null && !f.search.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR d.disease_name LIKE ?)");
            String p = "%" + f.search.trim() + "%";
            params.add(p); params.add(p);
        }
        if (f.riskLevel != null && !f.riskLevel.isBlank()) {
            sql.append(" AND dr.risk_level = ?");
            params.add(f.riskLevel.trim());
        }
        if (f.startDate != null && !f.startDate.isBlank()) {
            sql.append(" AND dr.created_at >= ?");
            params.add(f.startDate.trim() + " 00:00:00");
        }
        if (f.endDate != null && !f.endDate.isBlank()) {
            sql.append(" AND dr.created_at <= ?");
            params.add(f.endDate.trim() + " 23:59:59");
        }
        if (f.doctorId != null && !f.doctorId.isBlank()) {
            sql.append(" AND dr.reviewed_by_doctor_id = ?");
            params.add(f.doctorId.trim());
        }
        if (f.diseaseId != null && !f.diseaseId.isBlank()) {
            sql.append(" AND dr.disease_id = ?");
            params.add(f.diseaseId.trim());
        }
    }

    private static DiagnosisReport mapRow(ResultSet rs) throws SQLException {
        DiagnosisReport dr = new DiagnosisReport();
        dr.setId(rs.getString("id"));
        dr.setPatientId(rs.getString("patient_id"));
        dr.setDiseaseId(rs.getString("disease_id"));
        dr.setClinicId(rs.getString("clinic_id"));
        dr.setImageUrl(rs.getString("image_url"));
        dr.setHeatmapUrl(rs.getString("heatmap_url"));
        dr.setConfidenceScore(rs.getDouble("confidence_score"));
        dr.setRiskLevel(rs.getString("risk_level"));
        dr.setRecommendation(rs.getString("recommendation"));
        dr.setModelVersion(rs.getString("model_version"));
        Timestamp ca = rs.getTimestamp("created_at"); if (ca != null) dr.setCreatedAt(ca.toLocalDateTime());
        dr.setAiScreeningAttemptId(rs.getString("ai_screening_attempt_id"));
        dr.setInputImageObjectKey(rs.getString("input_image_object_key"));
        dr.setEigencamObjectKey(rs.getString("eigencam_object_key"));
        dr.setAiSuggestedDiseaseId(rs.getString("ai_suggested_disease_id"));
        dr.setDoctorReviewStatus(rs.getString("doctor_review_status"));
        dr.setReviewedByDoctorId(rs.getString("reviewed_by_doctor_id"));
        Timestamp reviewedAt = rs.getTimestamp("reviewed_at"); if (reviewedAt != null) dr.setReviewedAt(reviewedAt.toLocalDateTime());
        dr.setDoctorSelectedDiseaseId(rs.getString("doctor_selected_disease_id"));
        dr.setOverrideReason(rs.getString("override_reason"));
        dr.setDoctorNote(rs.getString("doctor_note"));
        dr.setPatientGuidance(rs.getString("patient_guidance"));
        dr.setPatientVisibilityStatus(rs.getString("patient_visibility_status"));
        dr.setDiseaseName(rs.getString("disease_name"));
        dr.setPatientName(rs.getString("patient_name"));
        dr.setPatientEmail(rs.getString("patient_email"));
        dr.setPatientPhone(rs.getString("patient_phone"));
        return dr;
    }
}

