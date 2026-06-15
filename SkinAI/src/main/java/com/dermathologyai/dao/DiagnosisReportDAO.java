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
        " d.disease_name, u.full_name AS patient_name" +
        " FROM diagnosis_reports dr" +
        " LEFT JOIN diseases d ON dr.disease_id = d.id" +
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

    /**
     * Find reports by patient ID with filters and sorting.
     */
    public List<DiagnosisReport> findByPatientIdFiltered(String patientId, String search, 
                                                         String fromDate, String toDate,
                                                         String riskLevel, String sort,
                                                         int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_COLS + " WHERE dr.patient_id = ?");
        List<Object> params = new ArrayList<>();
        params.add(patientId);
        
        appendPatientFilters(sql, params, search, fromDate, toDate, riskLevel);
        
        // Sorting
        String orderBy;
        switch (sort != null ? sort : "date") {
            case "confidence":
                orderBy = "dr.confidence_score DESC";
                break;
            case "risk":
                orderBy = "CASE dr.risk_level WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END";
                break;
            default: // "date"
                orderBy = "dr.created_at DESC";
                break;
        }
        
        sql.append(" ORDER BY ").append(orderBy).append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add((page - 1) * pageSize);
        params.add(pageSize);
        
        logger.debug("findByPatientIdFiltered SQL: {}", sql.toString());
        logger.debug("findByPatientIdFiltered params: {}", params);
        
        return queryList(sql.toString(), DiagnosisReportDAO::mapRow, params.toArray());
    }

    public int countByPatientId(String patientId) {
        return queryScalar(
            "SELECT COUNT(*) FROM diagnosis_reports WHERE patient_id = ?", patientId
        );
    }

    /**
     * Count reports by patient ID with filters.
     */
    public int countByPatientIdFiltered(String patientId, String search, 
                                        String fromDate, String toDate, String riskLevel) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM diagnosis_reports dr" +
            " LEFT JOIN diseases d ON dr.disease_id = d.id" +
            " WHERE dr.patient_id = ?"
        );
        List<Object> params = new ArrayList<>();
        params.add(patientId);
        
        appendPatientFilters(sql, params, search, fromDate, toDate, riskLevel);
        
        return queryScalar(sql.toString(), params.toArray());
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

    public String create(DiagnosisReport r) {
        String sql = "INSERT INTO diagnosis_reports" +
                     " (id, patient_id, disease_id, clinic_id, image_url, heatmap_url," +
                     " confidence_score, risk_level, recommendation, model_version)" +
                     " OUTPUT INSERTED.id VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        return insertReturningId(sql,
            r.getPatientId(), r.getDiseaseId(), r.getClinicId(),
            r.getImageUrl(), r.getHeatmapUrl(), r.getConfidenceScore(),
            r.getRiskLevel() != null ? r.getRiskLevel() : "LOW",
            r.getRecommendation(), r.getModelVersion()
        );
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

    /**
     * Append filters for patient-specific queries (no patient name search needed).
     */
    private static void appendPatientFilters(StringBuilder sql, List<Object> params,
                                            String search, String fromDate, String toDate, 
                                            String riskLevel) {
        if (search != null && !search.isBlank()) {
            sql.append(" AND d.disease_name LIKE ?");
            params.add("%" + search.trim() + "%");
        }
        if (fromDate != null && !fromDate.isBlank()) {
            sql.append(" AND CAST(dr.created_at AS DATE) >= ?");
            params.add(fromDate.trim());
        }
        if (toDate != null && !toDate.isBlank()) {
            sql.append(" AND CAST(dr.created_at AS DATE) <= ?");
            params.add(toDate.trim());
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
        dr.setDiseaseName(rs.getString("disease_name"));
        dr.setPatientName(rs.getString("patient_name"));
        return dr;
    }
}

