package com.skinai.dal;

import com.skinai.model.DiagnosisReport;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DiagnosisReportDAO {
    private static final Logger logger = LoggerFactory.getLogger(DiagnosisReportDAO.class);

    public DiagnosisReport findById(String id) {
        String sql = "SELECT dr.id, dr.patient_id, dr.disease_id, dr.clinic_id, dr.image_url, dr.heatmap_url, " +
                     "dr.confidence_score, dr.risk_level, dr.recommendation, dr.model_version, dr.created_at, " +
                     "d.disease_name, u.full_name as patient_name " +
                     "FROM diagnosis_reports dr " +
                     "LEFT JOIN diseases d ON dr.disease_id = d.id " +
                     "LEFT JOIN patients p ON dr.patient_id = p.id " +
                     "LEFT JOIN users u ON p.user_id = u.id " +
                     "WHERE dr.id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding diagnosis report by id: {}", id, e);
        }
        return null;
    }

    public List<DiagnosisReport> findByPatientId(String patientId, int page, int pageSize) {
        List<DiagnosisReport> list = new ArrayList<>();
        String sql = "SELECT dr.id, dr.patient_id, dr.disease_id, dr.clinic_id, dr.image_url, dr.heatmap_url, " +
                     "dr.confidence_score, dr.risk_level, dr.recommendation, dr.model_version, dr.created_at, " +
                     "d.disease_name, u.full_name as patient_name " +
                     "FROM diagnosis_reports dr " +
                     "LEFT JOIN diseases d ON dr.disease_id = d.id " +
                     "LEFT JOIN patients p ON dr.patient_id = p.id " +
                     "LEFT JOIN users u ON p.user_id = u.id " +
                     "WHERE dr.patient_id = ? " +
                     "ORDER BY dr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientId);
            ps.setInt(2, (page - 1) * pageSize);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding diagnosis reports by patientId: {}", patientId, e);
        }
        return list;
    }

    public int countByPatientId(String patientId) {
        String sql = "SELECT COUNT(*) FROM diagnosis_reports WHERE patient_id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patientId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error counting diagnosis reports by patientId: {}", patientId, e);
        }
        return 0;
    }

    public List<DiagnosisReport> findAll(int page, int pageSize) {
        List<DiagnosisReport> list = new ArrayList<>();
        String sql = "SELECT dr.id, dr.patient_id, dr.disease_id, dr.clinic_id, dr.image_url, dr.heatmap_url, " +
                     "dr.confidence_score, dr.risk_level, dr.recommendation, dr.model_version, dr.created_at, " +
                     "d.disease_name, u.full_name as patient_name " +
                     "FROM diagnosis_reports dr " +
                     "LEFT JOIN diseases d ON dr.disease_id = d.id " +
                     "LEFT JOIN patients p ON dr.patient_id = p.id " +
                     "LEFT JOIN users u ON p.user_id = u.id " +
                     "ORDER BY dr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, (page - 1) * pageSize);
            ps.setInt(2, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding all diagnosis reports", e);
        }
        return list;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM diagnosis_reports";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting diagnosis reports", e);
        }
        return 0;
    }

    public String create(DiagnosisReport report) {
        String sql = "INSERT INTO diagnosis_reports (id, patient_id, disease_id, clinic_id, image_url, heatmap_url, " +
                     "confidence_score, risk_level, recommendation, model_version) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, report.getPatientId());
            ps.setString(2, report.getDiseaseId());
            ps.setString(3, report.getClinicId());
            ps.setString(4, report.getImageUrl());
            ps.setString(5, report.getHeatmapUrl());
            ps.setDouble(6, report.getConfidenceScore());
            ps.setString(7, report.getRiskLevel() != null ? report.getRiskLevel() : "LOW");
            ps.setString(8, report.getRecommendation());
            ps.setString(9, report.getModelVersion());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating diagnosis report", e);
        }
        return null;
    }

    private DiagnosisReport mapRow(ResultSet rs) throws SQLException {
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
        if (rs.getTimestamp("created_at") != null) {
            dr.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        
        // Transient fields
        dr.setDiseaseName(rs.getString("disease_name"));
        dr.setPatientName(rs.getString("patient_name"));
        
        return dr;
    }
}
