package com.dermathologyai.dao;

import com.dermathologyai.model.DiagnosisReport;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * DAO for the diagnosis_reports table.
 * JOINs diseases, patients, and users for display-ready transient fields.
 */
public class DiagnosisReportDAO extends DBContext {
    private static final Logger logger = LoggerFactory.getLogger(DiagnosisReportDAO.class);

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

    public List<DiagnosisReport> findAll(String search, String riskLevel, String sort,
                                         int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_COLS + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, riskLevel);

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
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM diagnosis_reports dr" +
            " LEFT JOIN patients p ON dr.patient_id = p.id" +
            " LEFT JOIN users u ON p.user_id = u.id" +
            " LEFT JOIN diseases d ON dr.disease_id = d.id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, search, riskLevel);
        return queryScalar(sql.toString(), params.toArray());
    }

    public int countAll() {
        return countAll(null, null);
    }

    // ─── Dashboard analytics ───────────────────────────────────────────────────

    public Map<String, Integer> getRiskLevelDistribution() {
        Map<String, Integer> map = new HashMap<>();
        queryList(
            "SELECT COALESCE(risk_level, 'PENDING') AS risk_level, COUNT(*) AS cnt" +
            " FROM diagnosis_reports GROUP BY risk_level",
            rs -> { map.put(rs.getString("risk_level"), rs.getInt("cnt")); return null; }
        );
        return map;
    }

    public Map<String, Integer> getTopDiseases(int limit) {
        Map<String, Integer> map = new LinkedHashMap<>();
        // limit is not user input — safe to embed in SQL
        queryList(
            "SELECT TOP " + limit + " d.disease_name, COUNT(*) AS cnt" +
            " FROM diagnosis_reports dr JOIN diseases d ON dr.disease_id = d.id" +
            " GROUP BY d.disease_name ORDER BY cnt DESC, d.disease_name ASC",
            rs -> { map.put(rs.getString("disease_name"), rs.getInt("cnt")); return null; }
        );
        return map;
    }

    public Map<String, Integer> getScansTrend() {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        // Pre-fill 30 days with zeros so missing dates show up as 0 in the chart
        Map<String, Integer> map = new LinkedHashMap<>();
        for (int i = 29; i >= 0; i--) map.put(today.minusDays(i).format(fmt), 0);

        queryList(
            "SELECT CAST(created_at AS DATE) AS scan_date, COUNT(*) AS cnt" +
            " FROM diagnosis_reports WHERE created_at >= DATEADD(day, -30, GETDATE())" +
            " GROUP BY CAST(created_at AS DATE) ORDER BY scan_date ASC",
            rs -> {
                String date = rs.getString("scan_date");
                if (map.containsKey(date)) map.put(date, rs.getInt("cnt"));
                return null;
            }
        );
        return map;
    }

    public double getAverageConfidenceScore() {
        try (Connection conn = getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(
                 "SELECT COALESCE(AVG(confidence_score), 0.0) FROM diagnosis_reports")) {
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

    private static void appendFilters(StringBuilder sql, List<Object> params,
                                      String search, String riskLevel) {
        if (search != null && !search.isBlank()) {
            sql.append(" AND (u.full_name LIKE ? OR d.disease_name LIKE ?)");
            String p = "%" + search.trim() + "%";
            params.add(p); params.add(p);
        }
        if (riskLevel != null && !riskLevel.isBlank()) {
            sql.append(" AND dr.risk_level = ?");
            params.add(riskLevel.trim());
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

