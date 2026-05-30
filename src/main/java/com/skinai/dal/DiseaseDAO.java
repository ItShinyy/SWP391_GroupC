package com.skinai.dal;

import com.skinai.model.Disease;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DiseaseDAO {
    private static final Logger logger = LoggerFactory.getLogger(DiseaseDAO.class);

    public Disease findById(String id) {
        String sql = "SELECT id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty, created_at " +
                     "FROM diseases WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding disease by id: {}", id, e);
        }
        return null;
    }

    public Disease findByCode(String code) {
        String sql = "SELECT id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty, created_at " +
                     "FROM diseases WHERE disease_code = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error finding disease by code: {}", code, e);
        }
        return null;
    }

    public List<Disease> findAll() {
        List<Disease> list = new ArrayList<>();
        String sql = "SELECT id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty, created_at " +
                     "FROM diseases ORDER BY disease_name ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.error("Error finding all diseases", e);
        }
        return list;
    }

    public List<Disease> findAll(int page, int pageSize) {
        List<Disease> list = new ArrayList<>();
        String sql = "SELECT id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty, created_at " +
                     "FROM diseases ORDER BY disease_name ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
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
            logger.error("Error finding all diseases with pagination", e);
        }
        return list;
    }

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM diseases";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error counting diseases", e);
        }
        return 0;
    }

    public String create(Disease disease) {
        String sql = "INSERT INTO diseases (id, disease_name, disease_code, description, symptoms, severity_level, recommended_specialty) " +
                     "OUTPUT INSERTED.id " +
                     "VALUES (NEWID(), ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, disease.getDiseaseName());
            ps.setString(2, disease.getDiseaseCode());
            ps.setString(3, disease.getDescription());
            ps.setString(4, disease.getSymptoms());
            ps.setString(5, disease.getSeverityLevel() != null ? disease.getSeverityLevel() : "LOW");
            ps.setString(6, disease.getRecommendedSpecialty());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                }
            }
        } catch (SQLException e) {
            logger.error("Error creating disease", e);
        }
        return null;
    }

    public boolean update(Disease disease) {
        String sql = "UPDATE diseases SET disease_name = ?, disease_code = ?, description = ?, symptoms = ?, " +
                     "severity_level = ?, recommended_specialty = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, disease.getDiseaseName());
            ps.setString(2, disease.getDiseaseCode());
            ps.setString(3, disease.getDescription());
            ps.setString(4, disease.getSymptoms());
            ps.setString(5, disease.getSeverityLevel());
            ps.setString(6, disease.getRecommendedSpecialty());
            ps.setString(7, disease.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating disease: {}", disease.getId(), e);
        }
        return false;
    }

    public boolean delete(String id) {
        String sql = "DELETE FROM diseases WHERE id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting disease: {}", id, e);
        }
        return false;
    }

    private Disease mapRow(ResultSet rs) throws SQLException {
        Disease d = new Disease();
        d.setId(rs.getString("id"));
        d.setDiseaseName(rs.getString("disease_name"));
        d.setDiseaseCode(rs.getString("disease_code"));
        d.setDescription(rs.getString("description"));
        d.setSymptoms(rs.getString("symptoms"));
        d.setSeverityLevel(rs.getString("severity_level"));
        d.setRecommendedSpecialty(rs.getString("recommended_specialty"));
        if (rs.getTimestamp("created_at") != null) {
            d.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return d;
    }
}
